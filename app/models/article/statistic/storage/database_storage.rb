# frozen_string_literal: true

require 'bloomer/msgpackable'

class Article
  class Statistic
    class Storage
      class DatabaseStorage < MemoryStorage
        def remembers?(fingerprint)
          with_filter do |filter|
            filter.include?(fingerprint)
          end
        end

        def remember!(fingerprint)
          with_filter do |filter|
            filter.add(fingerprint)
          end
        end

        def with_filter(&block)
          statistic = article.statistic

          statistic.with_lock do
            filter = if statistic.filter_data.blank?
                       Bloomer::Scalable.new(expected_size, error_rate)
                     else
                       Bloomer.from_msgpack(statistic.filter_data)
                     end
            block.call(filter)
            statistic.update(filter_data: filter.to_msgpack)
          end
        end
      end
    end
  end
end
