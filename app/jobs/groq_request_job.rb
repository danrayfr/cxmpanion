require "faraday"
require "faraday/multipart"

class GroqRequestJob < ApplicationJob
  queue_as :default

  def perform(groq_request_params, groq_api_key)
    file = groq_request_params[:file]

    groq_transcriptions = Faraday.new(url: "https://api.groq.com/openai/v1/audio/transcriptions") do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    groq_translations = Faraday.new(url: "https://api.groq.com/openai/v1/audio/translations") do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    begin
      transcriptions = groq_transcriptions.post do |request|
        request.headers["Authorization"] = "Bearer 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"
        request.body = {
          file: Faraday::Multipart::FilePart.new(file, "audio/mp3"),
          model: "distil-whisper-large-v3-en",
          prompt: "Transcribe the audio as a conversation with multiple speakers. Label each speaker as 'Speaker 1', 'Speaker 2', and so on.",
          temperature: 0,
          response_format: "json",
          language: "en"
        }
      end

      translations = groq_translations.post do |request|
        request.headers["Authorization"] = "Bearer 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"
        request.body = {
          file: Faraday::Multipart::FilePart.new(file, "audio/mp3"),
          model: "distil-whisper-large-v3-en",
          prompt: "Transcribe the audio as a conversation with multiple speakers. Label each speaker as 'Speaker 1', 'Speaker 2', and so on.",
          temperature: 0,
          response_format: "json"
        }
      end



      parse_transcription = JSON.parse(transcriptions.body)
      generated_transcription = parse_transcription["text"]

      parse_translation = JSON.parse(translations.body)
      generated_translation = parse_transcription["text"]

      uuid = groq_request_params[:uuid]

      Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}", target: "groq_output", partial: "groq/output", locals: { generated_transcription:, generated_translation: })
    ensure
      File.delete(file) if File.exist?(file)
    end
  end
end
