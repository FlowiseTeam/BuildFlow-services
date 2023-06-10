module Api
  class ProjectsController < ApplicationController

    def index
      @projects = Project.all
      @project_count = Project.count
      if @project_count.zero?
        render json: { message: 'Nie znaleziono' }
      else
        render json: { projects: @projects, project_count: @project_count }
      end
    end

    def show
      begin
        @projects = Project.find(params[:id])
        render json: {projects: @projects}
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def create
      begin
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
      rescue StandardError => e
        render(json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error)
      end
    end

    def update
      begin
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
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def destroy
      begin
        @projects = Project.find(params[:id])
        @projects.destroy
        head :no_content
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

  end
end