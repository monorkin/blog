# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  layout 'public'
end
