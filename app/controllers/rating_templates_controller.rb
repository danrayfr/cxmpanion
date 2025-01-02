class RatingTemplatesController < ApplicationController
  before_action :set_rating_template, only: %i[ show edit update destroy ]

  def index
    @rating_templates = RatingTemplate.ordered
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @rating_template.to_json(include: { remarks: { only: %i[id body] } }) }
    end
  end

  def new
    @rating_template = RatingTemplate.new
  end

  def create
    @rating_template = RatingTemplate.new(rating_template_params)
    @rating_template.metrics = populate_metrics

    if @rating_template.save
      redirect_to rating_templates_url, notice: "Saved"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @rating_template.update(rating_template_params)
      redirect_to rating_templates_url, notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rating_template.destroy
    redirect_to rating_templates_url, notice: "Deleted"
  end

  private
    def rating_template_params
      params.require(:rating_template).permit(:name, :remarks, metrics: [ :metric_name, :deduction, :content ])
    end

    def set_rating_template
      @rating_template = RatingTemplate.find params[:id]
    end

    def populate_metrics
      metrics = []
      params[:metric_name]&.each_with_index do |metric_name, index|
        deduction = params[:deduction][index]
        content = params[:content][index]
        metric = { metric_name:, deduction:, content: }
        metrics << metric
      end

      metrics
    end
end
