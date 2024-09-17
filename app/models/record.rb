class Record < ApplicationRecord
  has_one_attached :file
  has_rich_text :transcript
  has_rich_text :analysis

  before_create { self.uid = generate_uid }

  def initialize_client
    @client = Groq::Client.new
  end

  def generate_response_user_role(message)
    initialize_client

    response = @client.chat([ { role: "user", content: message } ])

    response["content"]
  end

  def generate_response_system_role(message)
    initialize

    response = @client.chat([ { role: "system", content: message } ])

    response["content"]
  end

  private
    def generate_uid
      SecureRandom.uuid
    end
end
