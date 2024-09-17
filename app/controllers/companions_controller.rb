class CompanionsController < ApplicationController
  def index
    @uuid = SecureRandom.uuid
  end

  def groq_request
    file = ImportFileHandlerService.new.import(params[:groq_request][:file])

    if file[:content_type] == "audio/mpeg"
      TranscriptionJob.perform_later(groq_request_params.merge(file: file[:file_path].to_s))
    else
      generated_response = CompanionService.new.analyze("Can you please analyze and give me the name of the agent who's most efficient to least efficient? and how they can improve, how many time same tickets are returning to them? Please follow the this format and don't leave any more messages at the starafter the recommendation. Please don't include any names on your analysis, if possible, use 3rd person. or whatever you think is a red flag on the record<h1> Analysis </h1><h2> good </h2><ul>
    <li><p>The representative, Katya, greeted the customer, Sir Raul, and identified herself.</p></li>
    <li><p>She listened to the customer's concern and asked for the necessary information (PL number or telephone line connected to DSL) to assist him.</p></li>
    <li><p>She empathized with the customer's frustration and acknowledged the hassle caused by the issue.</p></li></ul><h2>
    Bad</h2><h2> Red flags </h2>Here is the conversation, I only need html formats, don't include any other formats such as json: \n#{file[:processed_rows]}", "no transcript")
      uuid = groq_request_params[:uuid]

      Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}", target: "groq_output", partial: "groq/output", locals: { generated_response: })
    end

    head :no_content
  end

  def import
    return redirect_to request.referrer, notice: "No file added" if params[:file].nil?
    # return redirect_to request.referrer, notice: "Only csv files allowed" unless params[:file].content_type == "text/csv"

    # csv = CsvImportService.new.call(params[:file])
    file = ImportFileHandlerService.new.import(params[:file])
    binding.b

    GroqRequestJob.perform_later(groq_request_params.merge(file: file.to_s), @groq_api_key)

    head :no_content

    # redirect_to request.referer, notice: "Import started..."
  end

  private
    def groq_request_params
      params.require(:groq_request).permit(:prompt, :format, :file, :uuid)
    end
end
