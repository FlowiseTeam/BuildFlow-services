module Api
  class EmployeesController < ApplicationController

    # GET /employees
    def index
      @employees = Employee.all
      @employees_count = Employee.count
      render json: { employees: @employees, employees_count: @employees_count }
    end

    # GET /employees/1
    def show
      @employees = Employee.find(params[:id])
      render json: {employees: @employees}
    end

    # POST /employees
    def create
      @employees = Employee.create(
        first_name:params[:first_name],
        last_name:params[:last_name],
        role: params[:role],
        assigned_project: params[:assigned_project],
        status:params[:status]
      )

      if @employees.save
        render json: {
          employees: @employees
        }, status: :created
      else
        render json: {
          error: @employees.errors.full_messages.to_sentence
        }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /employees/1
    def update
      @employees = Employee.find(params[:id])
      @employees.update(
        first_name:params[:first_name],
        last_name:params[:last_name],
        role: params[:role],
        assigned_project: params[:assigned_project],
        status:params[:status]
      )
      if @employees.save
        render json: {
          employees: @employees
        }, status: :ok
      else
        render json: {
          error: @employees.errors.full_messages.to_sentence
        }, status: :unprocessable_entity
      end
    end

    # DELETE /employees/1
    def destroy
      @employees = Employee.find(params[:id])
      @employees.destroy
      head :no_content
    end
  end
end
