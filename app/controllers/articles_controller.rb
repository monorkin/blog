class ArticlesController < ApplicationController
  ORDER = { published_at: :desc, id: :desc }
  RATIOS = [ 12, 25, 50 ]

  before_action only: %i[index show atom] do
    request.session_options[:skip] = true
  end

  before_action only: %i[show edit update destroy] do
    @article = Article.from_slug!(params[:slug])
  end

  before_action only: %i[new create edit update destroy] do
    unauthorized if Current.user.blank?
  end

  def index
    articles = if Current.user.present?
      scope
    else
      scope.published
    end

    set_page_and_extract_portion_from(articles, per_page: RATIOS)

    @articles = @page.records

    fresh_when(@articles)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def atom
    request.format = :atom

    @articles = scope.published.order(ORDER)
    fresh_when(@articles)
  end

  def show
    fresh_when(@article)
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(permitted_params)

    if @article.save
      redirect_to({ action: :show, slug: @article.slug }, status: :see_other)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(permitted_params)
      redirect_to({ action: :show, slug: @article.slug }, status: :see_other)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
        .with_rich_text_content_and_embeds
        .strict_loading
    end
end
