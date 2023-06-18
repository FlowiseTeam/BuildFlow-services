module Api
  class EmployeeAssignmentsController < ApplicationController

    def show
      begin
        if params[:project_id].present?
          @employee_assignments = EmployeeAssignment.where(project_id: params[:project_id])
        elsif params[:employee_id].present?
          @employee_assignments = EmployeeAssignment.where(employee_id: params[:employee_id])
        else
          return render json: { error: "Missing parameter: either project_id or employee_id must be provided" }, status: :bad_request
        end

        if @employee_assignments.empty?
          render json: { employee_assignments: []}, status: :ok
        else
          render json: { employee_assignments: @employee_assignments }, status: :ok
        end

      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def create
      begin
        @employee_assignment = EmployeeAssignment.create(
          project_id: params[:project_id],
          employee_id: params[:employee_id],
          project_name: params[:project_name]
        )

        if @employee_assignment.save
          render json: {
            employee_assignments: @employee_assignment
          }, status: :created
        else
          render json: {
            error: @employee_assignment.errors.full_messages.to_sentence
          }, status: :unprocessable_entity
        end
      rescue
        StandardError => e
        render(json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error)
      end
    end

    def destroy
      begin
        if params[:project_id].present?
          @employee_assignments = EmployeeAssignment.where(project_id: params[:project_id]).delete
        elsif params[:employee_id].present?
          @employee_assignments = EmployeeAssignment.where(employee_id: params[:employee_id]).delete
        else
          return render json: { error: "Missing parameter: either project_id or employee_id must be provided" }, status: :bad_request
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