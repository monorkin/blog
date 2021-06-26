3 # frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[6.0]
  def up
    # The following function encodes any string as Base58.
    # Base58 contains only URL safe characters and characters that don't look
    # similar.
    #
    # This implementation is compliant with:
    #   https://tools.ietf.org/id/draft-msporny-base58-01.html
    #
    # Examples:
    #   "Hello World!" => "2NEpo7TZRRrLZSi2U"
    #   "The quick brown fox jumps over the lazy dog." =>
    #     "USm3fpXnKG5EUBx2ndxBDMPVciP5hGey2Jh4NDv6gmeo1LkMeiKrLJUUBk6Z"
    #
    # This snippet is licensed under the MIT License:
    #
    # Copyright © 2020 Stanko K.R.
    #
    # Permission is hereby granted, free of charge, to any person obtaining a
    # copy of this software and associated documentation files (the “Software”),
    # to deal in the Software without restriction, including without limitation
    # the rights to use, copy, modify, merge, publish, distribute, sublicense,
    # and/or sell copies of the Software, and to permit persons to whom the
    # Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included
    # in all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
    # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    # IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    # CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
    # OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
    # THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #
    execute <<-SQL
    CREATE FUNCTION base58_encode(input_bytes bytea)
    RETURNS text AS $$
    DECLARE
      alphabet TEXT[] = array[
        '1','2','3','4','5','6','7','8','9',
        'A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T',
        'U','V','W','X','Y','Z',
        'a','b','c','d','e','f','g','h','i','j','k','m','n','o','p','q','r','s',
        't','u','v','w','x','y','z'
      ];
      output TEXT[] = ARRAY[]::TEXT[];
      digits INTEGER[] = ARRAY[0]::INTEGER[];
      i INTEGER = 0;
      j INTEGER = 0;
      carry INTEGER = 0;
    BEGIN
      IF octet_length(input_bytes) = 0 THEN
        RETURN ('');
      END IF;

      i := 0;
      WHILE i < octet_length(input_bytes) LOOP
        j := 1;

        WHILE j <= array_length(digits, 1) LOOP
          digits[j] := digits[j] << 8;
          j := j + 1;
        END LOOP;

        digits[1] := digits[1] + get_byte(input_bytes, i);
        carry := 0;
        j = 1;

        WHILE j <= array_length(digits, 1) LOOP
          digits[j] := digits[j] + carry;
          carry := digits[j] / 58;
          digits[j] := digits[j] % 58;
          j := j + 1;
        END LOOP;

        WHILE carry > 0 LOOP
          digits := digits || (carry % 58);
          carry := carry / 58;
        END LOOP;

        i := i + 1;
      END LOOP;

      i := 0;
      WHILE get_byte(input_bytes, i) = 0 AND i < octet_length(input_bytes) LOOP
        digits := digits || 0;
        i = i + 1;
      END LOOP;

      FOR g IN REVERSE array_length(digits, 1)..1 LOOP
        output := output || alphabet[digits[g] + 1];
      END LOOP;

      RETURN (array_to_string(output, '', ''));
    END; $$
    LANGUAGE PLPGSQL;
    SQL

    # The following function generates a random, short, 12 digit ID that is
    # URL safe.
    # Examples:
    #   5KQUy6eGYmAH
    #   5pXmPV3y4vcV
    #   2qHyFPm1J8b7
    #   vXgNCiDiBc3n
    #   3rxADaDLkJxe
    #
    # This snippet is licensed under the MIT License:
    #
    # Copyright © 2020 Stanko K.R.
    #
    # Permission is hereby granted, free of charge, to any person obtaining a
    # copy of this software and associated documentation files (the “Software”),
    # to deal in the Software without restriction, including without limitation
    # the rights to use, copy, modify, merge, publish, distribute, sublicense,
    # and/or sell copies of the Software, and to permit persons to whom the
    # Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included
    # in all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
    # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    # IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    # CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
    # OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
    # THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #
    execute <<-SQL
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";

    CREATE FUNCTION gen_random_shortid()
    RETURNS text AS $$
    BEGIN
      return (SUBSTRING(base58_encode(gen_random_bytes(12)), 0, 13));
    END; $$
    LANGUAGE PLPGSQL;
    SQL

    execute <<-SQL
      CREATE DOMAIN SHORTID as varchar(12)
      CHECK (VALUE ~ '^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$');
    SQL

    execute <<-SQL
    CREATE OR REPLACE FUNCTION assign_shortid()
    RETURNS TRIGGER AS $$
    DECLARE
      candidate_id SHORTID;
      i INTEGER = 0;
      max_iterations INTEGER = 100;
      found TEXT;
      id_exists_query TEXT;
    BEGIN
      IF NEW.id IS NOT NULL THEN
        RETURN NEW;
      END IF;

      id_exists_query :=
        'SELECT id FROM ' || quote_ident(TG_TABLE_NAME) || ' WHERE id=';

      LOOP
        IF i >= max_iterations THEN
          RAISE 'Could not generate a unique SHORTID in % iterations.', max_iterations;
        END IF;

        candidate_id := gen_random_shortid();

        EXECUTE id_exists_query || quote_literal(candidate_id) INTO found;

        IF found IS NULL THEN
          EXIT;
        END IF;

        i := i + 1;
      END LOOP;

      NEW.id = candidate_id;

      RETURN NEW;
    END
    $$ language 'plpgsql';
    SQL

    create_table :articles, id: :string do |t|
      t.text :title, null: false, default: ''
      t.text :content, null: false, default: ''
      t.text :slug, null: false, default: ''

      t.timestamps
    end

    execute <<-SQL
    CREATE TRIGGER gen_articles_id
    BEFORE INSERT ON articles
    FOR EACH ROW EXECUTE PROCEDURE assign_shortid();
    SQL
  end

  def down
    drop_table :articles

    execute 'DROP TRIGGER gen_articles_id ON articles;'
    execute 'DROP FUNCTION gen_random_shortid();'
    execute 'DROP FUNCTION base58_encode(bytea);'
    execute 'DROP DOMAIN shortid;'
  end
end
