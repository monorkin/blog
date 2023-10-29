class TalksController < ApplicationController
  ORDER = { held_at: :desc, title: :asc, event: :asc }
  RATIOS = [ 12, 25, 50 ]

  before_action only: %i[index show] do
    request.session_options[:skip] = true
  end

  before_action only: %i[show edit update destroy] do
    @talk = Talk.from_slug!(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise if Rails.env.local?
    redirect_to({ controller: :errors, action: :not_found }, status: :see_other)
  end

  before_action only: %i[new create edit update destroy] do
    unauthorized if Current.user.blank?
  end

  def index
    set_page_and_extract_portion_from(scope, per_page: RATIOS)

    @talks = @page.records

    fresh_when(@talks)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    fresh_when(@talk)
  end

  def new
    @talk = Talk.new
  end

  def create
    @talk = Talk.new(permitted_params)

    if @talk.save
      redirect_to({ action: :show, id: @talk }, status: :see_other)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @talk.update(permitted_params)
      redirect_to({ action: :show, id: @talk }, status: :see_other)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @talk.destroy!

    redirect_to({ action: :index }, status: :see_other)
  end

  private

    def permitted_params
      params.require(:talk).permit(:title, :event, :event_url,
        :video_mirror_url, :held_at, :video, :description)
    end

    def scope
      Talk.all.order(ORDER).with_rich_text_description_and_embeds.strict_loading
    end
end
