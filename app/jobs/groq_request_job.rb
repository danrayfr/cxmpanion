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
      transcription_result = parse_transcription["text"]

      parse_translation = JSON.parse(translations.body)
      translation_result = parse_transcription["text"]

      uuid = groq_request_params[:uuid]

      format = "- Please analyze the following customer representative conversation and break it down by good, bad, and red flags if there are serious no/red flag in the conversation, and don't add red flag(red flags are cursing the caller like tangina, fuck, mura, nagmumura, or whatever you think is a red flag on the record) if there is none, area for improvement, and recommendation on best handling the scenario. and please return the json response with the html tags so I can display it neatly on html. Please follow the this format and don't leave any more messages at the starafter the recommendation. Please don't include any names on your analysis, if possible, use 3rd person.<h1> Analysis </h1><h2> good </h2><ul>
    <li><p>The representative, Katya, greeted the customer, Sir Raul, and identified herself.</p></li>
    <li><p>She listened to the customer's concern and asked for the necessary information (PL number or telephone line connected to DSL) to assist him.</p></li>
    <li><p>She empathized with the customer's frustration and acknowledged the hassle caused by the issue.</p></li></ul><h2>
    Bad</h2><h2> Red flags </h2>Here is the conversation. I only need html format, don't include any formats such as json, etc. if possible also includes the timestamp of where do you think the reviewer should focus, specially on good, bad, and red flags."


      generated_response = CompanionService.new.analyze("#{format}\n\n#{transcription_result}")
      # generated_translation = CompanionService.new.analyze("#{format}\n\n#{translation_result}")

      # Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}", target: "groq_output", partial: "groq/output", locals: { generated_response: })

      # Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}", target: "groq_output", partial: "groq/output", locals: { generated_transcription:, generated_translation: })
    ensure
      File.delete(file) if File.exist?(file)
    end
  end
end
