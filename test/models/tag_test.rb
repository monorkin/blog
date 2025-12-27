# frozen_string_literal: true

require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test '.normalize_value_for :name' do
    assert_equal 'foo', Tag.normalize_value_for(:name, 'foo')
    assert_equal 'foo', Tag.normalize_value_for(:name, 'FOO')
    assert_equal 'foo', Tag.normalize_value_for(:name, ' Foo ')
    assert_equal 'foo', Tag.normalize_value_for(:name, '  Foo  ')
    assert_equal 'foo', Tag.normalize_value_for(:name, '  foo  ')
    assert_equal 'foo', Tag.normalize_value_for(:name, '  FOO  ')

    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'foo-bar')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'foo bar')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, ' foo  bar ')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'Foo Bar')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'Foo-Bar')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'FOO-Bar')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'FOO-BAR')
    assert_equal 'foo-bar', Tag.normalize_value_for(:name, 'Foo-BAR')

    assert_equal 'foo-bar-baz', Tag.normalize_value_for(:name, 'foo bar/baz')
    assert_equal 'foo-bar-baz', Tag.normalize_value_for(:name, 'foo bar+baz')
    assert_equal 'foo-bar-baz', Tag.normalize_value_for(:name, 'foo bar&baz')
    assert_equal 'foo-bar-baz', Tag.normalize_value_for(:name, 'foo bar_baz')
    assert_equal 'foo-bar-baz', Tag.normalize_value_for(:name, 'foo bar & baz')
  end
end
