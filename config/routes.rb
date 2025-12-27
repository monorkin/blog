# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'about#show'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'sitemap', to: 'sitemap#index'

  get 'login', to: 'login#new', as: :login
  post 'login', to: 'login#create'
  delete 'login', to: 'login#destroy'

  get 'search', to: 'search#index', as: :search
  get 'settings', to: 'settings#index', as: :settings

  resources :talks

  resources :articles, only: %i[index new create] do
    collection do
      get :rss, to: 'articles#atom', defaults: { format: :atom }
      get :atom, defaults: { format: :atom }
      get :atom_style, defaults: { format: :xsl }
    end
  end

  resources :articles, param: :slug, path: '', only: %i[show edit update destroy] do
    scope module: :articles do
      resources :link_previews, only: :show
    end
  end
end
