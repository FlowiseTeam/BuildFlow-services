module Api
  class ProjectsController < ApplicationController

    def index
      @projects = Project.all
      render json: @projects
    end

    def show
      @projects = Project.find(params[:id])
      render json: @projects
    end

    def create
      @projects = Project.create(
        name:params[:name],
        city:params[:city],
        client: params[:client]
      )
      render json: @projects
    end

    def update
      @projects = Project.find(params[:id])
      @projects.update(
        name:params[:name],
        city:params[:city],
        client: params[:client]
      )
      render json: @projects
    end

    def destroy
      @projects = Project.find(params[:id])
      @projects.destroy
      render json: @projects
    end

  end
end