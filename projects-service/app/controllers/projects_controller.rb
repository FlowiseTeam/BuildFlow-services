class ProjectsController < ApplicationController

  def index
    @projects = Project.all
    render json: @projects
  end

  def show
    @projects = Project.find(params[:id])
    render json: @projects
  end

end
