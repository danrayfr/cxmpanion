class CsvImportService
  require "csv"

  def call(file)
    opened_file = File.open(file)
    options = { headers: true, col_sep: ";", liberal_parsing: true }

    begin
      headers = []
      CSV.foreach(opened_file, **options).with_index do |row, index|
        if index == 0
          headers = row.headers # Get the dynamic headers
          Rails.logger.info "CSV Headers: #{headers.inspect}"
        else
          row_data = row.to_h # Convert the row to a hash using headers
          process_row(row_data, headers)
        end
      end
    rescue CSV::MalformedCSVError => e
      Rails.logger.error "CSV::MalformedCSVError: #{e.message}"
      { error: "Malformed CSV: #{e.message}" }
    end
  end

  private
    def process_row(data, headers)
      Rails.logger.info "Processing row: #{data.inspect} : #{headers.inspect}"
    end
end
