class CompanionService
  def analyze(prompt, transcript, file)
    # binding.b
    record = Record.new

    user_response = record.generate_response_user_role("#{prompt}#{transcript}")
    system_response = record.generate_response_system_role("#{prompt}#{transcript}")

    analysis = "#{user_response}\n\n#{system_response}"
    record.file.attach(io: file, filename: file.original_filename, content_type: file.content_type)
    record.transcript = transcript
    record.analysis = analysis

    record.save

    Rails.logger.info("Record ID: #{record.id}")

    "#{user_response}\n\n#{system_response}"
  end
end
