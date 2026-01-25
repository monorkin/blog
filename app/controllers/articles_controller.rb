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

    @articles = @page.records

    fresh_when(@page)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @related_articles = @article.related_articles(limit: 5)
    @previous_article = @article.previous_article
    @next_article = @article.next_article
    @popular_articles = Article.popular(limit: 5).where.not(id: @article.id)

    fresh_when etag: [ @article, @entry, @related_articles, @previous_article, @next_article, @popular_articles ]
  end

  def new
    @article = Article.new(entry: Entry.new)
  end

  def create
    @article = Article.new(article_params)

    Article.transaction do
      if @article.save
        @entry = Entry.create!(
          entryable: @article,
          slug: @article.title.parameterize,
          published: entry_params[:published] == "1",
          publish_at: entry_params[:publish_at],
          published_at: entry_params[:publish_at] || Time.current
        )
        @entry.tags = entry_params[:tags] if entry_params[:tags].present?
        redirect_to({ action: :show, slug: @entry.to_param }, status: :see_other)
      else
        @entry = Entry.new
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit; end

  def update
    Article.transaction do
      if @article.update(article_params)
        @entry.update!(
          slug: @article.title.parameterize,
          published: entry_params[:published] == "1",
          publish_at: entry_params[:publish_at]
        )
        @entry.tags = entry_params[:tags] if entry_params.key?(:tags)
        redirect_to({ action: :show, slug: @entry.to_param }, status: :see_other)
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @article.destroy!

    redirect_to({ action: :index }, status: :see_other)
  end

  private
    def set_article
      @entry = Entry.articles.from_slug!(params[:slug])
      @article = @entry.entryable
    end

    def article_params
      params.require(:article).permit(:title, :content)
    end

    def entry_params
      params.require(:article).permit(:publish_at, :published, :slug, :tags)
    end

    def scope
      Article
        .all
        .joins(:entry)
        .preload(:entry)
        .order(ORDER)
        .with_rich_text_content_and_embeds
        .strict_loading
    end
end
