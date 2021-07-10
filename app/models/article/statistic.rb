# frozen_string_literal: true

# == Schema Information
# Schema version: 20210125065024
#
# Table name: article_statistics
#
#  id                     :uuid             not null, primary key
#  referrer_visit_counts  :jsonb            not null
#  view_count             :bigint           default(0), not null
#  visit_counts_per_month :jsonb            not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  article_id             :string
#
# Indexes
#
#  index_article_statistics_on_article_id  (article_id)
#
class Article
  class Statistic < ApplicationRecord
    CONNECTION_POOL_OPTIONS = {
      size: ENV.fetch('RAILS_MAX_THREADS', 15),
      timeout: 5
    }.freeze

    belongs_to :article

    validates :article,
              presence: true

    after_initialize do
      self.referrer_visit_counts ||= {}
      self.referrer_visit_counts.default = 0

      self.visit_counts_per_month ||= {}
      self.visit_counts_per_month.default = 0
    end

    def self.redis_pool
      @redis_pool ||= ConnectionPool.new(CONNECTION_POOL_OPTIONS) { Redis.new }
    end

    def process_request_later(request)
      visit = Visit.new(article: article, request: request)
      return if visit.seen?

      store_visit!(visit)
      ProcessArticleVisitsJob.perform_later(self)
      visit.remember!
    end

    def process_visit!(visit)
      process_visit(visit)
      save!
    end

    def process_visit(visit)
      return if visit.seen?

      self.view_count += 1
      date_key = Date.current.strftime('%Y-%m')
      visit_counts_per_month[date_key] += 1

      return unless visit.referrer_host.present?

      referrer_visit_counts[visit.referrer_host] += 1
    end

    def store_visit!(visit)
      Apm.new.span(:store_visit) do
        self.class.redis_pool.with do |redis|
          redis.hsetnx(storage_key, visit.fingerprint, visit.to_json)
        end
      end

      true
    end

    def stored_visits
      Apm.new.span(:retrieve_stored_visits) do
        self.class
            .redis_pool
            .with { |redis| redis.hvals(storage_key) }
            .map { |visit_json| Visit.new(JSON.parse(visit_json)) }
      end
    end

    def clear_stored_visits!
      Apm.new.span(:clear_stored_visits) do
        self.class.redis_pool.with { |redis| redis.del(storage_key) }

        true
      end
    end

    private

    def storage_key
      "article/#{article.id}/statistic/visit_storage"
    end
  end
end
