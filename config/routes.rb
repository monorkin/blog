# frozen_string_literal: true

require 'resque'
require 'resque/server'

Rails.application.routes.draw do
  namespace :admin do
    mount Resque::Server.new, at: '/jobs'

    root to: 'articles#index'

    resource :sessions, only: %i[new create destroy]
    resources :users
    resources :articles, except: :index do
      collection do
        resources :imports, only: %i[new create]
      end

      resources :imports, only: %i[new create]
    end
  end

  namespace :public, path: '/' do
    get '404', to: 'errors#not_found'
    get '418', to: 'errors#im_a_teapot'
    get '422', to: 'errors#unprocessable_entity'
    get '451', to: 'errors#unavailable_for_legal_reasons'
    get '500', to: 'errors#internal_server_error'

    constraints subdomain: 'blog' do
      resources :articles, path: '/', only: %i[index] do
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

    constraints subdomain: '' do
      root to: 'about#show'
    end
  end
end
