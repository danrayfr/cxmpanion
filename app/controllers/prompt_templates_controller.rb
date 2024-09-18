class PromptTemplatesController < ApplicationController
  before_action :set_prompt_template, only: %i[ edit update destroy ]
  def index
    @prompt_templates = PromptTemplate.ordered
  end

  def new
    @prompt_template = PromptTemplate.new
  end

  def create
    @prompt_template = PromptTemplate.new(template_params)

    if @prompt_template.save
      redirect_to prompt_templates_url, notice: "Added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @prompt_template.update(template_params)
      redirect_to prompt_templates_url, notice: "Updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prompt_template.destroy
    redirect_to prompt_templates_url, notice: "Delete."
  end

  private
    def template_params
      params.require(:prompt_template).permit(:name, :task, :format)
    end

    def set_prompt_template
      @prompt_template = PromptTemplate.find params[:id]
    end
end
