module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate

    etag { Current.user&.id }
  end

  class_methods do
    def ensure_authenticated(**options)
      before_action :require_authentication, **options
    end
  end

  private
    def authenticate
      Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def require_authentication
      render({ file: Rails.root.join("public/401.html"), status: :unauthorized, layout: false }) unless Current.user.present?
    end
end
