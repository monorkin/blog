# frozen_string_literal: true

class PublicController < ApplicationController
  UNSET = Object.new

  layout 'public'

  helper_method :display_header
  helper_method :display_footer

  after_action -> { request.session_options[:skip] = true }

  def self.display_header(value = UNSET)
    @display_header = true if @display_header.nil?
    return @display_header if value == UNSET

    @display_header = !!value
  end

  def self.display_footer(value = UNSET)
    @display_footer = true if @display_footer.nil?
    return @display_footer if value == UNSET

    @display_footer = !!value
  end

  def display_header
    self.class.display_header
  end

  def display_footer
    self.class.display_footer
  end

  def current_user
    nil
  end
end
