require "securerandom"

class PagesController < ApplicationController
  def index
    @uuid = SecureRandom.uuid
  end

  def groq_request
    uploaded_file = params[:groq_request][:file]
    temp_file_path = Rails.root.join("tmp", uploaded_file.original_filename)

    File.open(temp_file_path, "wb") do |file|
      file.write(uploaded_file.read)
    end

    GroqRequestJob.perform_later(groq_request_params.merge(file: temp_file_path.to_s), @groq_api_key)

    head :no_content
  end

  private
    def groq_request_params
      params.require(:groq_request).permit(:file, :uuid)
    end
end
