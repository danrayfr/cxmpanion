class CompanionService
  def analyze(prompt, transcript, file)
    record = Record.new

    user_response = record.generate_response_user_role("#{prompt}#{transcript}")
    system_response = record.generate_response_system_role("#{prompt}#{transcript}")

    analysis = "#{user_response}\n\n#{system_response}"
    record.file.attach(io: file, filename: file.original_filename, content_type: file.content_type)
    record.transcript = transcript
    record.analysis = analysis

    record.save

    "#{user_response}\n\n#{system_response}"
  end
end
