module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.settings = Settings.new(cookies.to_h.slice("color_scheme"))
      ActiveStorage::Current.url_options = Rails.application.default_url_options
    end
  end
end
