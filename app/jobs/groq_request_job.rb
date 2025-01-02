require "faraday"
require "faraday/multipart"

class GroqRequestJob < ApplicationJob
  queue_as :default

  def perform(groq_request_params)
    file = groq_request_params[:file]
    prompt = groq_request_params[:prompt]
    format = groq_request_params[:format]
    uuid = groq_request_params[:uuid]
    groq_api_key = groq_request_params[:groq_api_key]

    groq_transcriptions = Faraday.new(url: "https://api.groq.com/openai/v1/audio/transcriptions") do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    # groq_translations = Faraday.new(url: "https://api.groq.com/openai/v1/audio/translations") do |faraday|
    #   faraday.request :multipart
    #   faraday.request :url_encoded
    #   faraday.adapter Faraday.default_adapter
    # end

    begin
      transcriptions = groq_transcriptions.post do |request|
        request.headers["Authorization"] = "Bearer #{groq_api_key}"
        request.body = {
          file: Faraday::Multipart::FilePart.new(file, "audio/mp3"),
          model: "distil-whisper-large-v3-en",
          prompt: "Transcribe the audio as a conversation with multiple speakers. Label each speaker as 'Speaker 1', 'Speaker 2', and so on.",
          temperature: 0,
          response_format: "json",
          language: "en"
        }
      end

      parse_transcription = JSON.parse(transcriptions.body)
      transcript = parse_transcription["text"]

      # parse_translation = JSON.parse(translations.body)
      # translation_result = parse_transcription["text"]

      record = Record.new
      user_response = record.generate_response_user_role("#{prompt}\n#{format}\n#{transcript}")
      system_response = record.generate_response_system_role("#{prompt}\n#{format}\n#{transcript}")

      generated_response = "#{user_response}\n\n#{system_response}"

      Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}", target: "companion_output", partial: "groq/output", locals: { transcript:, generated_response: })
    ensure
      File.delete(file) if File.exist?(file)
    end
  end
end
