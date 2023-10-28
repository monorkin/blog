# frozen_string_literal: true

class Settings < ApplicationModel
  COLOR_SCHEMES = %w[auto light dark].freeze
  DEFAULT_COLOR_SCHEME = "auto".freeze

  attr_accessor :color_scheme

  alias _color_scheme= color_scheme=

  def color_scheme=(value)
    value = value.to_s.downcase.strip.presence
    # The sensible thing here would be to raise an error but that could
    # potentially break the UI for someone. So, instead, we'll just set the
    # value to nil and let the code handle this as if the value is unset
    value = nil unless COLOR_SCHEMES.include?(value)

    self._color_scheme = value
  end

  def color_scheme_or_default
    color_scheme || DEFAULT_COLOR_SCHEME
  end

  COLOR_SCHEMES.each do |name|
    define_method("color_scheme_#{name}?") do
      color_scheme_or_default == name
    end
  end
end
