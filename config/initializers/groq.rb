# frozen_string_literal: true

Groq.configure do |config|
  config.api_key = ENV["GROQ_API_KEY"]
  config.model_id = "llama3-70b-8192"
end
