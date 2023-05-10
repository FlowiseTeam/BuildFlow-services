module Api
  class ProjectsController < ApplicationController

    def index
      @projects = Project.all
      @project_count = Project.count
      render json: { projects: @projects, project_count: @project_count }
    end

    def show
      @projects = Project.find(params[:id])
      render json: {projects: @projects}
    end

    def create
      @projects = Project.create(
        city:params[:city],
        client:params[:client],
        start_date: params[:start_date],
        end_date: params[:end_date],
        name:params[:name],
        status:params[:status],
        street: params[:street],
        zipcode:params[:zipcode]
      )

      if @projects.save
        render json: {
          projects: @projects
        }, status: :created
      else
        render json: {
          error: @projects.errors.full_messages.to_sentence
        }, status: :unprocessable_entity
      end
    end

    def update
      @projects = Project.find(params[:id])
      @projects.update(
        city:params[:city],
        client:params[:client],
        start_date: params[:start_date],
        end_date: params[:end_date],
        name:params[:name],
        status:params[:status],
        street: params[:street],
        zipcode:params[:zipcode]
      )

      if @projects.save
        render json: {
          projects: @project
        }, status: :ok
      else
        render json: {
          error: @projects.errors.full_messages.to_sentence
        }, status: :unprocessable_entity
      end
    end

    def destroy
      @projects = Project.find(params[:id])
      @projects.destroy
      head :no_content
    end
  end
end