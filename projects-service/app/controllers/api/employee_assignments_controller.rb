module Api
  class EmployeeAssignmentsController < ApplicationController

    #def show
    #  @employee_assignment = EmployeeAssignment.find_by(project_id: params[:project_id], employee_id: params[:id])

    # if @employee_assignment
    #    render json: {
    #      employee_assignment: @employee_assignment
    #    }, status: :ok
    #  else
    #    render json: {
    #      error: 'Employee assignment not found'
    #    }, status: :not_found
    #  end
    #end

    def show_by_employee
      @employee_assignments = EmployeeAssignment.where(employee_id: params[:employee_id])

      render json: {
        employee_assignments: @employee_assignments
      }, status: :ok
    end

    def show_by_project
      @project = Project.find(params[:project_id])
      @employee_assignments = @project.employee_assignments

      render json: {
        employee_assignments: @employee_assignments
      }, status: :ok
    end

    def create
      @project = Project.find(params[:project_id])

      @employee_assignment = @project.employee_assignments.build(
        project_id: @project.id,
        employee_id: params[:employee_id],
        project_name: params[:project_name]
      )

      if @employee_assignment.save
        render json: {
          employee_assignments: @employee_assignment
        }, status: :created, location: api_project_employee_assignment_url(@project, @employee_assignment)
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

    private

  end
end