module Api
  class VehicleAssignmentsController < ApplicationController

    def show
      begin
        if params[:project_id].present?
          @vehicle_assignments = VehicleAssignment.where(project_id: params[:project_id])
        elsif params[:vehicle_id].present?
          @vehicle_assignments = VehicleAssignment.where(vehicle_id: params[:vehicle_id])
        else
          return render json: { error: "Missing parameter: either project_id or vehicle_id must be provided" }, status: :bad_request
        end

        if @vehicle_assignments.empty?
          render json: { vehicle_assignments: []}, status: :ok
        else
          render json: { vehicle_assignments: @vehicle_assignments }, status: :ok
        end

      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def create
      begin
        @vehicle_assignments = VehicleAssignment.create(
          project_id: params[:project_id],
          vehicle_id: params[:vehicle_id],
          project_name: params[:project_name]
        )

        if @vehicle_assignments.save
          render json: { vehicle_assignments: @vehicle_assignments }, status: :created
        else
          render json: { error: @vehicle_assignments.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def destroy
      begin
        if params[:project_id].present?
          @vehicle_assignments = VehicleAssignment.where(project_id: params[:project_id]).delete
        elsif params[:vehicle_id].present?
          @vehicle_assignments = VehicleAssignment.where(vehicle_id: params[:vehicle_id]).delete
        else
          return render json: { error: "Missing parameter: either project_id or vehicle_id must be provided" }, status: :bad_request
        end
          head :no_content
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

  end
end