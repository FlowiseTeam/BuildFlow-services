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
          render json: { employees: [] }, status: :ok
        else
          employee_ids = @employees.map { |employee| employee['_id'] }
          uri = URI("#{ENV['PROJECTS_SERVICE']}/employee_assignments")
          uri.query = URI.encode_www_form({ 'employee_ids' => employee_ids.join(',') })

          auth_header = request.headers['Authorization']

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri)
          request['Authorization'] = auth_header

          response = http.request(request)

          assignments = if response.is_a?(Net::HTTPSuccess)
                          JSON.parse(response.body)['employee_assignments'] || []
                        else
                          []
                        end

          assignments_map = assignments.each_with_object({}) do |assignment, map|
            (map[assignment['employee_id']] ||= []) << assignment
          end

          employees_with_assigned_projects = @employees.map do |employee|
            {
              _id: employee['_id'],
              created_at: employee['created_at'],
              updated_at: employee['updated_at'],
              first_name: employee['first_name'],
              last_name: employee['last_name'],
              role: employee['role'],
              qualifications: employee['qualifications'],
              assigned_project: assignments_map[employee['_id']] || [],
              status: employee['status']
            }
          end

          render json: { employees: employees_with_assigned_projects, employees_count: @employees_count }, status: :ok
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
          uri.query = URI.encode_www_form({ 'employee_id' => params[:id] })

          auth_header = request.headers['Authorization']

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri)
          request['Authorization'] = auth_header

          response = http.request(request)

          if response.is_a?(Net::HTTPSuccess)
            data = JSON.parse(response.body)
            employee_assignments_data = data['employee_assignments']
          end
        rescue StandardError => e
          employee_assignments_data = ['Błąd brak połączenia z serwisem']
        end
        @employee[:assigned_project] = employee_assignments_data

        render json: { employee: @employee }, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # POST /employees
    def create
      begin
        @employee = Employee.new(
          first_name: params[:first_name],
          last_name: params[:last_name],
          role: params[:role],
          status: params[:status],
          qualifications: params[:qualifications]
        )
        if @employee.save
          render json: { employee: @employee }, status: :created
        else
          render json: { error: @employee.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # PATCH/PUT /employees/1
    def update
      begin
        @employee = Employee.find(params[:id])
        @employee.update(
          first_name: params[:first_name],
          last_name: params[:last_name],
          role: params[:role],
          status: params[:status],
          qualifications: params[:qualifications]
        )

        @employee[:assigned_project] = params[:assigned_project]
        begin
          uri = URI("#{ENV['PROJECTS_SERVICE']}/employee_assignments")
          uri.query = URI.encode_www_form({ 'employee_id' => params[:id] })

          auth_header = request.headers['Authorization']

          http = Net::HTTP.new(uri.host, uri.port)

          delete_request = Net::HTTP::Delete.new(uri.request_uri)
          delete_request['Authorization'] = auth_header
          http.request(delete_request)

          unless params[:assigned_project].nil? || params[:assigned_project].empty?
            employee_assignments_data = []
            params[:assigned_project].each do |assigned_project|
              logger.info(assigned_project)
              post_request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
              post_request['Authorization'] = auth_header
              post_request.body = { employee_id: params[:id], project_id: assigned_project[:project_id], project_name: assigned_project[:project_name] }.to_json

              response = http.request(post_request)
              if response.is_a?(Net::HTTPSuccess)
                data = JSON.parse(response.body)
                employee_assignments_data << data['employee_assignments']
              end
            end
          end
        rescue StandardError => e
          employee_assignments_data = ['Błąd brak połączenia z serwisem']
        end
        @employee[:assigned_project] = employee_assignments_data

        if params[:assigned_project].empty?
          @employee[:status] = 'Nieprzypisany'
        else
          @employee[:status] = 'Przypisany'
        end

        if @employee.save
          render json: { employees: @employee }, status: :ok
        else
          render json: { error: @employee.errors.full_messages.to_sentence }, status: :unprocessable_entity
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
