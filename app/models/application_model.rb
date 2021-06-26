# frozen_string_literal: true

class ApplicationModel
  include ActiveModel::Model

  define_model_callbacks :initialize

  def initialize(...)
    run_callbacks :initialize do
      super(...)
    end
  end
end
