class RecordsController < ApplicationController
  def new
    @record = Record.new
  end

  def create
    @record = Record.new
    message = params[:message]

    user_response = @record.generate_response_user_role(message)
    system_response = @record.generate_response_system_role(message)

    response = "#{user_response}\n\n#{system_response}"

    respond_to do |format|
      format.html { render :new, locals: { response: } }  # Render the new view with the response
      format.json { render json: { response: } }          # For JSON format
      format.turbo_stream { render turbo_stream: turbo_stream.replace("response", partial: "records/response", locals: { response: }) }  # For Turbo Stream
    end
  end
end
