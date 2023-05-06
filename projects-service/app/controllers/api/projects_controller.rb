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
        city:params[:city],
        client:params[:client],
        start_date: params[:start_date],
        end_date: params[:end_date],
        name:params[:name],
        status:params[:status],
        street: params[:street],
        zipcode:params[:zipcode]
      )
      render json: @projects
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
      render json: @projects
    end

    def destroy
      @projects = Project.find(params[:id])
      @projects.destroy
      render json: @projects
    end

  end
end