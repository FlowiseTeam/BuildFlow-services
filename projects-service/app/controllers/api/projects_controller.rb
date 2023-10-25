module Api
  class ProjectsController < ApplicationController

    def index
      begin
        @projects = Project.all
        @project_count = Project.count
        # @assigned_employees = EmployeeAssignment.where(project_id: params[:id])
        # @assigned_employees = VehicleAssignment.where(project_id: params[:id])
        if @project_count.zero?
          render json: { projects: [] }, status: :ok
        else
          # projects_with_assignments = @projects.map do |project|
          #   assigned_employees = EmployeeAssignment.where(project_id: project.id).pluck(:employee_id)
          #   assigned_vehicles = VehicleAssignment.where(project_id: project.id).pluck(:vehicle_id)
          #   project.attributes.merge(employees: assigned_employees,vehicles: assigned_vehicles)
          # end
          render json: { projects: @projects, project_count: @project_count }
        end
      rescue
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def show
      begin
        @projects = Project.find(params[:id])
        employee_ids = EmployeeAssignment.where(project_id: @projects.id).pluck(:employee_id)
        vehicle_ids = VehicleAssignment.where(project_id: @projects.id).pluck(:vehicle_id)
        project_data = @projects.attributes.merge(vehicles: vehicle_ids,employees: employee_ids)

        render json: {projects: project_data}
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    def process_subcontractors(subcontractor_params)
      return [] unless subcontractor_params

      subcontractor_params.map do |subcontractor|
        {
          name: subcontractor[:name] || "",
          email: subcontractor[:email] || "",
          address: subcontractor[:address] || "",
          phone: subcontractor[:phone] || ""
        }
      end
    end

    def create
      begin
        @projects = Project.create(
          city: params[:city],
          client: params[:client],
          start_date: params[:start_date],
          end_date: params[:end_date],
          name: params[:name],
          status: params[:status],
          street: params[:street],
          zipcode: params[:zipcode],
        )

        if @projects.save
          render json: {
            project: @projects
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
        subcontractors = process_subcontractors(params[:subcontractors])

        @projects = Project.find(params[:id])
        @projects.update(
          city:params[:city],
          client:params[:client],
          start_date: params[:start_date],
          end_date: params[:end_date],
          name:params[:name],
          status:params[:status],
          street: params[:street],
          zipcode:params[:zipcode],
          subcontractors: subcontractors
        )

        # EmployeeAssignment.where(project_id: params[:id]).delete
        # VehicleAssignment.where(project_id: params[:id]).delete
        #
        # unless params[:employees].empty?
        #   params[:employees].each do |employee_id|
        #     EmployeeAssignment.create!(project_id: params[:id], employee_id: employee_id, project_name: params[:name])
        #   end
        # end
        # unless params[:vehicles].empty?
        #   params[:vehicles].each do |vehicle_id|
        #     VehicleAssignment.create!(project_id: params[:id], vehicle_id: vehicle_id, project_name: params[:name])
        #   end
        # end

        if @projects.save
          render json: {
            projects: @projects
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
        EmployeeAssignment.where(project_id: params[:id]).delete
        VehicleAssignment.where(project_id: params[:id]).delete
        head :no_content

      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

  end
end