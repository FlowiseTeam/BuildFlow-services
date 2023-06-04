module Api
  class EmployeeAssignmentsController < ApplicationController

    def show
      if params[:project_id].present?
        @employee_assignments = EmployeeAssignment.where(project_id: params[:project_id])
      elsif params[:employee_id].present?
        @employee_assignments = EmployeeAssignment.where(employee_id: params[:employee_id])
      else
        return render json: { error: "Missing parameter: either project_id or employee_id must be provided" }, status: :bad_request
      end

      render json: {
        employee_assignments: @employee_assignments
      }, status: :ok
    end

    def create
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
    end

    def destroy
      @employee_assignment = EmployeeAssignment.find(params[:id])
      @employee_assignment.destroy
      head :no_content
    end

  end
end