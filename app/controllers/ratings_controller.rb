class RatingsController < ApplicationController
  before_action :set_record
  before_action :check_if_rating_exist, only: :new
  before_action :set_rating, only: %i[ edit update destroy ]

  def new
    @rating = @record.build_rating
  end

  def create
    @rating = @record.build_rating(rating_params)

    @rating.metrics = populate_metrics

    if @rating.save
      redirect_to @record, notice: "Rating added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @rating.update(rating_params)
      redirect_to @record, notice: "Rating updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rating.destroy
    redirect_to @record, notice: "Rating deleted successfully."
  end

  private
    def rating_params
      params.require(:rating).permit(:score, :metrics, :remarks, :record_id)
    end

    def set_record
      @record = Record.find params[:record_id]
    end

    def set_rating
      @rating = Rating.find params[:id]
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

    def check_if_rating_exist
      if @record.rating.present?
        redirect_to @record, alert: "Rating already exists.", status: :found
      end
    end
end
