# frozen_string_literal: true

require 'test_helper'
require 'axe/matchers/be_axe_clean'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_firefox

  def assert_accessible(page, matcher: nil, options: {})
    matcher ||= Axe::Matchers::BeAxeClean.new

    options.each do |name, value|
      matcher = matcher.public_send(name, value)
    end

    assert(!matcher.matches?(page), matcher.failure_message)
  end
end
