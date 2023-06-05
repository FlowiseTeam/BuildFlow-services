module Api
  class EmployeesController < ApplicationController
    require 'uri'
    require 'net/http'
    # GET /employees
    def index
      @employees = Employee.all
      @employees_count = Employee.count
      render json: { employees: @employees, employees_count: @employees_count }
    end

    # GET /employees/1
    def show
      @employee = Employee.find(params[:id])

      begin
        uri = URI('http://127.0.0.1:3000/api/projects/employee_assignments')
        uri.query = URI.encode_www_form({'employee_id' => params[:id]})

        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)
          employee_assignments_data = data['employee_assignments']
        else
          employee_assignments_data = ["Błąd wczytywania danych"]
        end

      rescue StandardError => e
        employee_assignments_data = ["Błąd połączenia"]
      end

      @employee[:assigned_project] = employee_assignments_data

      render json: {employee: @employee}
    end


    # POST /employees
    def create
      @employees = Employee.create(
        first_name:params[:first_name],
        last_name:params[:last_name],
        role: params[:role],
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
