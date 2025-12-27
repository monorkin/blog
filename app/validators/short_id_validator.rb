# frozen_string_literal: true

class ShortIdValidator < ActiveModel::EachValidator
  SHORT_ID_REGEX = /^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{12}$/

  def validate_each(record, attribute, value)
    return if value.match?(SHORT_ID_REGEX)

    record.errors.add(attribute, options[:message] || :invalid_short_id)
  end
end
