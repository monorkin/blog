# frozen_string_literal: true

module Article::ReadingTimeEstimatable
  AVERAGE_WORDS_PER_MINUTE = 225

  extend ActiveSupport::Concern

  def estimated_reading_time(words_per_minute: AVERAGE_WORDS_PER_MINUTE)
    [ (word_count.to_f / words_per_minute).ceil, 1 ].max.to_i
  end

  def word_count
    plain_text_content.scan(/\w+/).flatten.count
  end
end
