module Api
  class EmployeesController < ApplicationController
    require 'uri'
    require 'net/http'

    # GET /employees
    def index
      begin
        @employees = Employee.all
        @employees_count = Employee.count

        if @employees_count.zero?
          render json: { error: 'Brak rekordów' }, status: :not_found
        else
          employees_with_assigned_projects = @employees.map do |employee|
            begin
            uri = URI("#{ENV['PROJECTS_SERVICE']}/employee_assignments")
            uri.query = URI.encode_www_form({'employee_id' => employee['_id']})
            response = Net::HTTP.get_response(uri)

            if response.is_a?(Net::HTTPSuccess)
              data = JSON.parse(response.body)
              employee_assignments_data = data['employee_assignments']
            end
            rescue StandardError => e
              employee_assignments_data = ['Błąd brak połączenia z tabelą']
            end
            {
              _id: employee['_id'],
              created_at: employee['created_at'],
              updated_at: employee['updated_at'],
              first_name: employee['first_name'],
              last_name: employee['last_name'],
              role: employee['role'],
              qualifications: employee['qualifications'],
              assigned_project: employee_assignments_data,
              status: employee['status']
            }
          end

          render json: { employees: employees_with_assigned_projects, employees_count: @employees_count }
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # GET /employees/1
    def show
      begin
        @employee = Employee.find(params[:id])
        begin
          "#{ENV['PROJECTS_SERVICE']}/employee_assignments"
          uri = URI("#{ENV['PROJECTS_SERVICE']}/employee_assignments")
          uri.query = URI.encode_www_form({'employee_id' => params[:id]})

          response = Net::HTTP.get_response(uri)

          if response.is_a?(Net::HTTPSuccess)
            data = JSON.parse(response.body)
            employee_assignments_data = data['employee_assignments']
          end
        rescue StandardError => e
          employee_assignments_data = ['Błąd brak połączenia z tabelą']
        end
        @employee[:assigned_project] = employee_assignments_data

        render json: {employee: @employee}
      rescue Mongoid::Errors::DocumentNotFound
        render(json: { error: 'Nie znaleziono rekordu' }, status: :not_found)
      rescue StandardError => e
        render(json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error)
      end
    end


    # POST /employees
    def create
      begin
        @employees = Employee.create(
          first_name:params[:first_name],
          last_name:params[:last_name],
          role: params[:role],
          status:params[:status],
          qualifications: params[:qualifications]
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
      rescue StandardError => e
        render(json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error)
      end
    end

    # PATCH/PUT /employees/1
    def update
      begin
        @employees = Employee.find(params[:id])
        @employees.update(
          first_name: params[:first_name],
          last_name: params[:last_name],
          role: params[:role],
          status: params[:status],
          qualifications: params[:qualifications]
        )
        begin
          uri = URI("#{ENV['PROJECTS_SERVICE']}/employee_assignments")
          uri.query = URI.encode_www_form({'employee_id' => params[:id]})

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Delete.new(uri.request_uri)

          response = http.request(request) # TODO handle errors

          unless params[:assigned_project].empty?
            params[:assigned_project].each do |assigned_project|
              logger.info(assigned_project)
              request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
              request.body = {employee_id: params[:id], project_id: assigned_project[:project_id], project_name: assigned_project[:project_name]}.to_json
              response = http.request(request)
            end
          end
        rescue StandardError => e
        end

        if @employees.save
          render json: {
            employees: @employees
          }, status: :ok
        else
          render json: {
            error: @employees.errors.full_messages.to_sentence
          }, status: :unprocessable_entity
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # DELETE /employees/1
    def destroy
      begin
        @employee = Employee.find(params[:id])
        @employee.destroy
        head :no_content
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

  end
end
