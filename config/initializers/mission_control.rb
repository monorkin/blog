# frozen_string_literal: true

MissionControl::Jobs.http_basic_auth_enabled = false

Rails.application.config.to_prepare do
  MissionControl::Jobs::ApplicationController.class_eval do
    include Authentication
    ensure_authenticated
  end
end
