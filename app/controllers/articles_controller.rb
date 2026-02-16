# frozen_string_literal: true

class ArticlesController < ApplicationController
  ORDER = { "entries.published_at" => :desc, "articles.id" => :desc }.freeze
  RATIOS = [ 12, 25, 50 ].freeze

  before_action only: %i[index show] do
    request.session_options[:skip] = true
  end

  before_action :set_article, only: %i[show edit update destroy]
  ensure_authenticated only: %i[new create edit update destroy]

  def index
    articles = if Current.user.present?
      scope
    else
      scope.published
    end

    set_page_and_extract_portion_from(articles, per_page: RATIOS)

    @entries = @page.records.map(&:entry)

    fresh_when(@page)
  end

  def show
    @related_articles = @article.related_articles(limit: 5)
    @previous_article = @article.previous_article
    @next_article = @article.next_article
    @popular_articles = Article.popular(limit: 5).where.not(id: @article.id)

    fresh_when etag: [ @article, @article.entry, @related_articles, @previous_article, @next_article, @popular_articles ]
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(permitted_params)

    if @article.save
      redirect_to({ action: :show, slug: @article.to_param }, status: :see_other)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @article.update(permitted_params)
      redirect_to({ action: :show, slug: @article.to_param }, status: :see_other)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy!

    redirect_to({ action: :index }, status: :see_other)
  end

  private
    def set_article
      @article = Entry.articles.from_slug!(params[:slug]).entryable
    end

    def permitted_params
      params.require(:article).permit(:title, :body, :publish_at, :published, :tags)
    end

    def scope
      Article
        .all
        .joins(:entry)
        .preload(:entry)
        .order(ORDER)
        .with_rich_text_body_and_embeds
        .strict_loading
    end
end
