class ImportFileHandlerService
  def import(file)
    if file.content_type == "text/csv"
      csv_handle(file)
    elsif file.content_type == "audio/mpeg"
      audio_handler(file)
    else
      Rails.logger.info "file is not supported"
    end
  end

  private
    def csv_handle(uploaded_file)
      opened_file = File.open(uploaded_file)
      options = { headers: true, col_sep: ";", liberal_parsing: true }
      processed_rows = []

      begin
        headers = []
        CSV.foreach(opened_file, **options).with_index do |row, index|
          if index == 0
            headers = row.headers
            Rails.logger.info "CSV Headers: #{headers.inspect}"
          else
            # row_data = row.to_h
            processed_rows << row.to_h
          end
        end
      rescue CSV::MalformedCSVError => e
        Rails.logger.error "CSV::MalformedCSVError: #{e.message}"
        { error: "Malformed CSV: #{e.message}" }
      end
      { content_type: uploaded_file.content_type, processed_rows: }
    end

    def audio_handler(uploaded_file)
      temp_file_path = Rails.root.join("tmp", uploaded_file.original_filename)

      File.open(temp_file_path, "wb") do |file|
        file.write(uploaded_file.read)
      end

      { content_type: uploaded_file.content_type, file_path: temp_file_path.to_s, uploaded_file: uploaded_file }

      # GroqRequestJob.perform_later(groq_request_params.merge(file: temp_file_path.to_s), @groq_api_key)
    end

    def process_row(data, headers)
      Rails.logger.info "Processing row: #{data.inspect} : #{headers.inspect}"
    end

    def groq_request_params
      params.require(:groq_request).permit(:file, :uuid)
    end
end
