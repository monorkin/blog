# frozen_string_literal: true

class AdminController < ApplicationController
  include Authenticatable

  layout 'admin'
  authenticate!
end
