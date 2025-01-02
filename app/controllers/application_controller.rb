class ApplicationController < ActionController::Base
  before_action :set_groq_api_key
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_groq_api_key
    @groq_api_key = ENV["GROQ_API_KEY"]
  end
end
