class RecordsController < ApplicationController
  before_action :set_groq_api_key, only: :create
  before_action :set_record, only: %i[ show edit update destroy ]

  def index
    @records = Record.ordered
  end

  def new
    @record = Record.new
  end

  def show
  end

  def create
    file = ImportFileHandlerService.new.import(record_params[:file])

    if file[:content_type] == "audio/mpeg"
      TranscriptionJob.perform_later(record_params.merge(file: file[:file_path].to_s, groq_api_key: @groq_api_key))
    elsif file[:content_type] == "text/csv"
      generated_response = CompanionService.new.analyze("#{record_params[:prompt]}\n#{record_params[:format]}\n #{file[:processed_rows]}", "", record_params[:file])
    end

    redirect_to records_url
  end

  def edit
  end

  def update
    if @record.update(update_params)
      redirect_to record_path(@record), notice: "Successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    redirect_to records_url, notice: "Successfully deleted."
  end

  private
    def record_params
      params.require(:record).permit(:prompt, :format, :file)
    end

    def update_params
      params.require(:record).permit(:uid, :file, :transcript, :analysis)
    end

    def set_record
      @record = Record.find params[:id]
    end

    def set_groq_api_key
      @groq_api_key = ENV["GROQ_API_KEY"]
    end
end
