# frozen_string_literal: true

class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Kredis::Attributes

  define_model_callbacks :initialize

  def initialize(...)
    run_callbacks :initialize do
      super(...)
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
