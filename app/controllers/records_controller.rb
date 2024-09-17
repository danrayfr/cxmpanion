class RecordsController < ApplicationController
  def index
    @record = Record.new
  end

  def new
  end

  def create
    # @record = Record.new(record_params)

    file = ImportFileHandlerService.new.import(params[:record][:file])

    if file[:content_type] == "audio/mpeg"
      TranscriptionJob.perform_later(record_params.merge(file: file[:file_path].to_s))
    elsif file[:content_type] == "text/csv"

      generated_response = CompanionService.new.analyze("#{prompt}\n #{file[:processed_rows]}", "no_transcript", record_params[:file])
      # uuid = groq_request_params[:uuid]

      # Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}", target: "groq_output", partial: "groq/output", locals: { generated_response: })
    end

    # binding.b


    # message = params[:message]

    # user_response = @record.generate_response_user_role(message)
    # system_response = @record.generate_response_system_role(message)
#
    # response = "#{user_response}\n\n#{system_response}"
#
    # respond_to do |format|
    #   format.html { render :new, locals: { response: } }  # Render the new view with the response
    #   format.json { render json: { response: } }          # For JSON format
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace("response", partial: "records/response", locals: { response: }) }  # For Turbo Stream
    # end
  end

  private
    def record_params
      params.require(:record).permit(:prompt, :file)
    end

    def prompt
      "Can you please analyze and give me the name of the agent who's most efficient to least efficient? and how they can improve, how many time same tickets are returning to them? Please follow the this format and don't leave any more messages at the starafter the recommendation. Please don't include any names on your analysis, if possible, use 3rd person. or whatever you think is a red flag on the record<h1> Analysis </h1><h2> good </h2><ul><li><p>The representative, Katya, greeted the customer, Sir Raul, and identified herself.</p></li><li><p>She listened to the customer's concern and asked for the necessary information (PL number or telephone line connected to DSL) to assist him.</p></li><li><p>She empathized with the customer's frustration and acknowledged the hassle caused by the issue.</p></li></ul><h2>Bad</h2><h2> Red flags </h2>Here is the conversation, I only need html formats, don't include any other formats such as json: "
    end
end
