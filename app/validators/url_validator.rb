# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  URI_REGEX = URI::DEFAULT_PARSER.make_regexp.freeze
  LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze

  def validate_each(record, attribute, value)
    if invalid?(value)
      return record.errors.add(attribute, options[:message] || :invalid_url)
    end

    if loopback?(value)
      return record.errors.add(attribute, options[:message] || :loopback_url)
    end
  end

  def invalid?(value)
    !value&.to_s&.match?(URI_REGEX)
  end

  def loopback?(value)
    return false unless options.key?(:loopback)
    return false if options[:loopback]

    uri = URI(value)

    LOOPBACK_HOSTS.include?(uri.host)
  end
end
