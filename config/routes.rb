# frozen_string_literal: true

require 'resque'
require 'resque/server'

Rails.application.routes.draw do
  root to: 'about#show'

  get '404', to: 'errors#not_found'
  get '418', to: 'errors#im_a_teapot'
  get '422', to: 'errors#unprocessable_entity'
  get '451', to: 'errors#unavailable_for_legal_reasons'
  get '500', to: 'errors#internal_server_error'

  get 'sitemap', to: 'sitemap#index'

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
