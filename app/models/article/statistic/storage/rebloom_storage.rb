# frozen_string_literal: true

require 'bloomer/msgpackable'

class Article
  class Statistic
    class Storage
      class RebloomStorage < Storage
        CONNECTION_POOL_OPTIONS = {
          size: ENV.fetch('RAILS_MAX_THREADS', 15),
          timeout: 5
        }.freeze

        def self.rebloom_pool
          @rebloom_pool ||= ConnectionPool.new(CONNECTION_POOL_OPTIONS) do
            Redis.new(url: ENV.fetch('REBLOOM_URL'))
          end
        end

        def remembers?(fingerprint)
          with_filter do |redis|
            redis.synchronize do
              redis.call(['BF.EXISTS', filter_key, fingerprint]) == 1
            end
          end
        end

        def remember!(*fingerprints)
          with_filter do |redis|
            redis.synchronize do
              redis.call(['BF.MADD', filter_key, *fingerprints]) == 1
            end
          end
        end

        def with_filter(&block)
          self.class.rebloom_pool.with do |redis|
            with_lock(redis) do
              create_filter!(redis)

              block.call(redis)
            end
          end
        end

        def create_filter!(redis)
          redis.synchronize do
            redis.call ['BF.RESERVE', filter_key, error_rate, expected_size, 'EXPANSION', 2]
          end
        rescue Redis::CommandError => e
          return true if e.message == 'ERR item exists'

          raise e
        end

        def with_lock(redis, &block)
          lock_manager = Redlock::Client.new([redis])
          result = nil
          lock_info = nil

          10.times do
            lock_info = lock_manager.lock(lock_key, 100)
            sleep(0.05) and next unless lock_info

            result = block.call

            lock_manager.unlock(lock_info)
            break
          end

          result
        ensure
          lock_manager&.unlock(lock_info) if lock_info
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
