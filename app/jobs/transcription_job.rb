require "faraday"
require "faraday/multipart"

class TranscriptionJob < ApplicationJob
  queue_as :default

  def perform(request_params)
    file = request_params[:file]

    prompt = request_params[:prompt]
    format = request_params[:format]
    groq_api_key = request_params[:groq_api_key]

    transcription_api = Faraday.new(
                    url: "https://api.groq.com/openai/v1/audio/transcriptions") do |faraday|
                        faraday.request :multipart
                        faraday.request :url_encoded
                        faraday.adapter Faraday.default_adapter
                    end

    begin
      transcription = transcription_api.post do |request|
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

      transcripted = JSON.parse(transcription.body)
      transcript = transcripted["text"]

      task = "#{prompt}\n\n#{format}"

      generated_response = CompanionService.new.analyze(task, transcript, Faraday::Multipart::FilePart.new(file, "audio/mp3"))

      Turbo::StreamsChannel.broadcast_update_to("records", target: "record_output", partial: "records/output", locals: { transcript:, generated_response: })
    ensure
      File.delete(file) if File.exist?(file)
    end
  end
end
