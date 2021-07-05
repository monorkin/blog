# frozen_string_literal: true

require 'resque'
require 'resque/server'

Rails.application.routes.draw do
  namespace :admin do
    constraints(lambda { |request| request.session[Authenticatable::CURRENT_USER_SESSION_KEY].present? }) do
      mount Resque::Server.new, at: '/resque'
    end

    root to: 'articles#index'

    resource :sessions, only: %i[new create destroy]
    resource :jobs, only: :show
    resources :users
    resources :articles, except: :index do
      collection do
        resources :imports, only: %i[new create]
      end

      resources :imports, only: %i[new create]
    end
  end

  namespace :public, path: '/' do
    root to: 'about#show'

    get '404', to: 'errors#not_found'
    get '418', to: 'errors#im_a_teapot'
    get '422', to: 'errors#unprocessable_entity'
    get '451', to: 'errors#unavailable_for_legal_reasons'
    get '500', to: 'errors#internal_server_error'

    resources :articles, only: %i[index] do
      collection do
        get :rss
        get :atom
      end
    end

    resources :articles, param: :slug, path: '', only: %i[show] do
      scope module: :articles do
        resource :analytics, only: :show
        resources :link_previews, only: :show
      end
    end
  end
end
