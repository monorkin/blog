# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"

  root to: "about#show"

  get "/sitemap.xml", to: "sitemaps#index", as: :sitemap, defaults: { format: :xml }
  get "/sitemap-pages.xml", to: "sitemaps#pages", as: :sitemap_pages, defaults: { format: :xml }
  get "/sitemap-articles.xml", to: "sitemaps#articles", as: :sitemap_articles, defaults: { format: :xml }
  get "/sitemap-talks.xml", to: "sitemaps#talks", as: :sitemap_talks, defaults: { format: :xml }
  get "/sitemap-tags.xml", to: "sitemaps#tags", as: :sitemap_tags, defaults: { format: :xml }

  get "login", to: "login#new", as: :login
  post "login", to: "login#create"
  delete "login", to: "login#destroy"

  get "search", to: "search#index", as: :search
  get "settings", to: "settings#index", as: :settings

  resources :tags, only: :show, param: :name

  resources :talks

  resources :articles, only: %i[index new create] do
    collection do
      get :rss, to: "articles#atom", defaults: { format: :atom }
      get :atom, defaults: { format: :atom }
      get :atom_style, defaults: { format: :xsl }
    end
  end

  resources :articles, param: :slug, path: "", only: %i[show edit update destroy] do
    scope module: :articles do
      resources :link_previews, only: :show
    end
  end
end
