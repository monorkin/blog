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

  # Unified feed with type filtering
  get "feed", to: "feed#show", as: :feed, defaults: { format: :atom }
  get "feed/style", to: "feed#style", as: :feed_style, defaults: { format: :xsl }

  resources :tags, only: :show, param: :name do
    collection do
      resources :suggestions, only: :index, module: :tags
    end
  end

  resources :talks

  resources :snaps do
    collection do
      resources :galleries, only: :show, module: :snaps, param: :slug
    end
  end

  resources :articles, only: %i[index new create] do
    collection do
      # Legacy redirects - preserve tag param, add types=article filter
      get :rss, to: redirect { |_, req|
        query = { types: "article" }
        query[:tag] = req.params[:tag] if req.params[:tag].present?
        "/feed?#{query.to_query}"
      }, status: 301
      get :atom, to: redirect { |_, req|
        query = { types: "article" }
        query[:tag] = req.params[:tag] if req.params[:tag].present?
        "/feed?#{query.to_query}"
      }, status: 301
      get :atom_style, to: redirect("/feed/style"), status: 301
    end
  end

  resources :articles, param: :slug, path: "", only: %i[show edit update destroy] do
    scope module: :articles do
      resources :link_previews, only: :show, param: :base64_encoded_url
    end
  end
end
