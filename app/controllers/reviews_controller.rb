class ReviewsController < ApplicationController
  before_action :set_record
  before_action :set_review, only: %i[ edit update destroy ]

  def new
    @review = @record.reviews.build
  end

  def create
    @review = @record.reviews.build(review_params)

    if @review.save
      redirect_to @record, notice: "Reviewed."
    else
      redirect_to :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to @record, notice: "Updated."
    else
      redirect_to :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to @record, notice: "Review deleted successfully."
  end

  private
    def review_params
      params.require(:review).permit(:assignee, :name, :remarks, :record_id)
    end

    def set_record
      @record = Record.find params[:record_id]
    end

    def set_review
      @review = Review.find params[:id]
    end
end
