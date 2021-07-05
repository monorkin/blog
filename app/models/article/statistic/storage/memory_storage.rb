# frozen_string_literal: true

class Article
  class Statistic
    class Storage
      class MemoryStorage < Storage
        def self.mutex
          @mutex ||= Mutex.new
        end

        def self.filter_for(key, size, error_rate, &block)
          mutex.synchronize do
            @filters ||= {}
            filter = @filters[key] ||= Bloomer::Scalable.new(size, error_rate)

            block.call(filter)
          end
        end

        def remembers?(fingerprint)
          with_filter do |filter|
            filter.include?(fingerprint)
          end
        end

        def remember!(*fingerprints)
          with_filter do |filter|
            fingerprints.each { |fingerprint| filter.add(fingerprint) }
          end
        end

        def with_filter(&block)
          self.class.filter_for(fingerprint_key, expected_size, error_rate) do |filter|
            block.call(filter)
          end
        end

        def fingerprint_key
          "analytics.article.#{article.id}.fingerprints"
        end
      end
    end
  end
end
