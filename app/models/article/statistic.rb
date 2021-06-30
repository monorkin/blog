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
    belongs_to :article

    validates :article,
              presence: true

    after_initialize do
      self.referrer_visit_counts ||= {}
      self.referrer_visit_counts.default = 0

      self.visit_counts_per_month ||= {}
      self.visit_counts_per_month.default = 0
    end

    def log_visit_later(request)
      visit = Visit.new(request: request)
    end

    def log_visit!(request)
      visit = Visit.new(request: request)
      return if visit.seen?

      self.view_count += 1
      date_key = Date.current.strftime('%Y-%m')
      visit_counts_per_month[date_key] += 1

      visit.processed!

      return unless visit.referrer_host.present?

      referrer_visit_counts[visit.referrer_host] += 1
    ensure
      save!
    end
  end
end
