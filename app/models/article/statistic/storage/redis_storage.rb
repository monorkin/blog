# frozen_string_literal: true

require 'bloomer/msgpackable'

class Article
  class Statistic
    class Storage
      class RedisStorage < Storage
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
          Article::Statistic.redis_pool.with do |redis|
            with_lock(redis) do
              filter = filter_from_data(redis.get(filter_key))

              block.call(filter)

              redis.set(filter_key, encode_filter(filter)) if save
            end
          end
        end

        def filter_from_data(data)
          return Bloomer::Scalable.new(expected_size, error_rate) if data.blank?

          Bloomer.from_msgpack(Base64.decode64(data))
        end

        def encode_filter(filter)
          Base64.encode64(filter.to_msgpack)
        end

        def with_lock(redis, &block)
          lock_manager = Redlock::Client.new([redis])

          20.times do
            lock_info = lock_manager.lock(lock_key, 2000)

            unless lock_info
              sleep 0.1
              next
            end

            block.call

            lock_manager.unlock(lock_info)
            break
          end
        end

        def lock_key
          "#{filter_key}/lock"
        end

        def filter_key
          "article/#{article.id}/statistics/fingerprint_bloom_filter"
        end
      end
    end
  end
end
