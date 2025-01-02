require "faraday"
require "faraday/multipart"

class CompanionsController < ApplicationController
  before_action :generate_uuid, only: :index
  before_action :groq_api_key, only: :groq_request

  def groq_request
    file = ImportFileHandlerService.new.import(params[:groq_request][:file])

    if file[:content_type] == "audio/mpeg"
      GroqRequestJob.perform_later(groq_request_params.merge(file: file[:file_path].to_s, groq_api_key: @groq_api_key))
    else
      record = Record.new
      user_response = record.generate_response_user_role("#{groq_request_params[:prompt]}\n#{groq_request_params[:format]}\n#{file}")
      system_response = record.generate_response_system_role("#{groq_request_params[:prompt]}\n#{groq_request_params[:format]}\n#{file}")

      generated_response = "#{user_response}\n\n#{system_response}"

      Turbo::StreamsChannel.broadcast_update_to("channel_#{groq_request_params[:uuid]}", target: "companion_output", partial: "groq/output", locals: { transcript: file, generated_response: })
    end

    head :no_content
  end

  private
    def groq_request_params
      params.require(:groq_request).permit(:prompt, :format, :file, :uuid)
    end

    def transcribe
      Faraday.new(url: "https://api.groq.com/openai/v1/audio/transcriptions") do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
      end
    end

    def groq_api_key
      @groq_api_key = ENV["GROQ_API_KEY"]
    end

    def generate_uuid
      @uuid = SecureRandom.uuid
    end
end
