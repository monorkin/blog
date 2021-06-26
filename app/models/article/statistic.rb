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

    validates :article, presence: true
  end
end
