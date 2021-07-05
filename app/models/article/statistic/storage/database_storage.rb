# frozen_string_literal: true

require 'bloomer/msgpackable'

class Article
  class Statistic
    class Storage
      class DatabaseStorage < Storage
        def remembers?(fingerprint)
          with_filter do |filter|
            filter.include?(fingerprint)
          end
        end

        def remember!(*fingerprints)
          with_filter(save: true) do |filter|
            fingerprints.each { |fingerprint| filter.add(fingerprint) }
          end
        end

        def with_filter(save: false, &block)
          statistic = article.statistic

          statistic.with_lock do
            filter = if statistic.filter_data.blank?
                       Bloomer::Scalable.new(expected_size, error_rate)
                     else
                       Bloomer.from_msgpack(statistic.filter_data)
                     end
            block.call(filter)
            statistic.update(filter_data: filter.to_msgpack) if save
          end
        end
      end
    end
  end
end
