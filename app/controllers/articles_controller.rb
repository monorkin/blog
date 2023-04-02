# frozen_string_literal: true

class ArticlesController < ApplicationController
  ORDER = { published_at: :desc, id: :desc }
  RATIOS = [ 10, 20, 30, 50 ]

  def index
    request.session_options[:skip] = true

    articles = if Current.user.present?
      scope
    else
      scope.published
    end

    set_page_and_extract_portion_from(articles, per_page: RATIOS)

    @articles = @page.records

    fresh_when(@articles)
  end

  def atom
    request.session_options[:skip] = true

    return(head :internal_server_error) if feed.invalid?

    headers['Content-Type'] = 'application/atom+xml'

    render xml: feed.to_atom, layout: false
  end

  def show
    request.session_options[:skip] = true

    @article = Article.from_slug!(params[:slug])

    fresh_when(@article)
  end

  def new
    return unauthorized if Current.user.blank?

    @article = Article.new
  end

  def create
    return unauthorized if Current.user.blank?

    @article = Article.new(permitted_params)

    if @article.save
      redirect_to({ action: :show, slug: @article.slug }, status: :see_other)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    return unauthorized if Current.user.blank?

    @article = Article.from_slug!(params[:slug])
  end

  def update
    return unauthorized if Current.user.blank?

    @article = Article.from_slug!(params[:slug])

    if @article.update(permitted_params)
      redirect_to({ action: :show, slug: @article.slug }, status: :see_other)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return unauthorized if Current.user.blank?

    @article = Article.from_slug!(params[:slug])
    @article.destroy!

    redirect_to({ action: :index }, status: :see_other)
  end

  private

  def permitted_params
    params.require(:article).permit(:title, :content, :publish_at, :published,
      :slug)
  end

  def scope
    Article
      .all
      .order(ORDER)
      .with_rich_text_content
      .strict_loading
  end

  def feed
    @feed ||= Article::Feed.new(
      scope: scope.published.preload(:attachments),
      host: request.host_with_port
    )
  end
end
