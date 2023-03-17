SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: shortid; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.shortid AS character varying(12)
	CONSTRAINT shortid_check CHECK (((VALUE)::text ~ '^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$'::text));


--
-- Name: assign_shortid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_shortid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
    $$;


--
-- Name: base58_encode(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base58_encode(input_bytes bytea) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
    END; $$;


--
-- Name: gen_random_shortid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_random_shortid() RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
      return (SUBSTRING(base58_encode(gen_random_bytes(12)), 0, 13));
    END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: article_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_attachments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    attachment_data jsonb,
    article_id character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    original_path text
);


--
-- Name: article_taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_taggings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    article_id character varying NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.articles (
    id character varying NOT NULL,
    title text DEFAULT ''::text NOT NULL,
    content text DEFAULT ''::text NOT NULL,
    slug text DEFAULT ''::text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    publish_at timestamp without time zone,
    published boolean DEFAULT false NOT NULL,
    published_at timestamp(6) without time zone GENERATED ALWAYS AS (COALESCE(publish_at, created_at)) STORED,
    thread character varying,
    searchable tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('english'::regconfig, title), 'A'::"char") || setweight(to_tsvector('english'::regconfig, content), 'B'::"char"))) STORED
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name public.citext,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    username text,
    password_digest text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    unconfirmed_otp_secret text,
    otp_secret text,
    last_otp_used_at timestamp without time zone,
    last_login_at timestamp without time zone
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: article_attachments article_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_attachments
    ADD CONSTRAINT article_images_pkey PRIMARY KEY (id);


--
-- Name: article_taggings article_taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_taggings
    ADD CONSTRAINT article_taggings_pkey PRIMARY KEY (id);


--
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_article_attachments_on_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_attachments_on_article_id ON public.article_attachments USING btree (article_id);


--
-- Name: index_article_attachments_on_article_id_and_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_article_attachments_on_article_id_and_primary ON public.article_attachments USING btree (article_id, "primary") WHERE ("primary" = true);


--
-- Name: index_article_attachments_on_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_attachments_on_primary ON public.article_attachments USING btree ("primary");


--
-- Name: index_article_taggings_on_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_taggings_on_article_id ON public.article_taggings USING btree (article_id);


--
-- Name: index_article_taggings_on_article_id_and_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_article_taggings_on_article_id_and_tag_id ON public.article_taggings USING btree (article_id, tag_id);


--
-- Name: index_article_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_taggings_on_tag_id ON public.article_taggings USING btree (tag_id);


--
-- Name: index_articles_on_published_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_published_at ON public.articles USING btree (published_at);


--
-- Name: index_articles_on_searchable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_searchable ON public.articles USING gin (searchable);


--
-- Name: index_articles_on_thread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_thread ON public.articles USING btree (thread);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: articles gen_articles_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gen_articles_id BEFORE INSERT ON public.articles FOR EACH ROW EXECUTE FUNCTION public.assign_shortid();


--
-- Name: article_taggings fk_rails_29f3e7b135; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_taggings
    ADD CONSTRAINT fk_rails_29f3e7b135 FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: article_taggings fk_rails_3679f80ade; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_taggings
    ADD CONSTRAINT fk_rails_3679f80ade FOREIGN KEY (article_id) REFERENCES public.articles(id);


--
-- Name: article_attachments fk_rails_95824e00d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_attachments
    ADD CONSTRAINT fk_rails_95824e00d3 FOREIGN KEY (article_id) REFERENCES public.articles(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20200930123607'),
('20200930142931'),
('20201001112541'),
('20201001125739'),
('20201004050725'),
('20201005063507'),
('20201005133456'),
('20201008145546'),
('20201008145937'),
('20210124095936'),
('20210124171805'),
('20210125065024'),
('20210627083831'),
('20210704144106'),
('20220905160355'),
('20220905165144'),
('20220925093723'),
('20230317081456');


