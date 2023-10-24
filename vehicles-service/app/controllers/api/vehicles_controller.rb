module Api
  class VehiclesController < ApplicationController
    require 'uri'
    require 'net/http'
    before_action :set_vehicle, only: %i[ show update destroy ]

    # GET /vehicles
    # GET /vehicles.json
    def index
      begin
        @vehicles = Vehicle.all
        @vehicles_count = Vehicle.count

        if @vehicles_count.zero?
          render json: { message: 'Nie znaleziono' }, status: :not_found
        else
          vehicles_with_assigned_projects = @vehicles.map do |vehicle|
            uri = URI("#{ENV['PROJECTS_SERVICE']}/vehicle_assignments")
            uri.query = URI.encode_www_form({'vehicle_id' => vehicle['_id']})
            response = Net::HTTP.get_response(uri)

            if response.is_a?(Net::HTTPSuccess)
               data = JSON.parse(response.body)
               vehicles_assignments_data = data['vehicle_assignments']
            else
              vehicles_assignments_data = [uri,puts(ENV['PROJECTS_SERVICE'])]
            end

            {
              _id: vehicle['_id'],
              created_at: vehicle['created_at'],
              updated_at: vehicle['updated_at'],
              name: vehicle['name'],
              status: vehicle['status'],
              mileage: vehicle['mileage'],
              reg_number: vehicle['reg_number'],
              rev_date: vehicle['rev_date'],
              assigned_project: vehicles_assignments_data,
              capacity: vehicle['capacity'],
            }
          end

          render json: { vehicles: vehicles_with_assigned_projects, vehicles_count: @vehicles_count }
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
        # rescue StandardError => e
        #  render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # GET /vehicles/1
    # GET /vehicles/1.json
    def show
      begin
        @vehicles = Vehicle.find(params[:id])

        #"#{ENV['PROJECTS_SERVICE']}/employee_assignments"
        uri = URI("#{ENV['PROJECTS_SERVICE']}/vehicle_assignments")
        uri.query = URI.encode_www_form({'vehicle_id' => params[:id]})

        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)
          vehicle_assignments_data = data['vehicle_assignments']
        else
          vehicle_assignments_data = []
        end
        @vehicles[:assigned_project] = vehicle_assignments_data

        render json: {vehicle: @vehicles}
      rescue Mongoid::Errors::DocumentNotFound
        render(json: { error: 'Nie znaleziono' }, status: :not_found)
      rescue StandardError => e
        render(json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error)
      end
    end

    # POST /vehicles
    # POST /vehicles.json
    def create
      begin
        @vehicles = Vehicle.create(
          name:params[:name],
          status:params[:status],
          mileage: params[:mileage],
          reg_number:params[:reg_number]
        )
        if @vehicles.save
          render json: {
            vehicles: @vehicles
          }, status: :created
        else
          render json: {
            error: @vehicles.errors.full_messages.to_sentence
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render(json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error)
      end
    end

    # PATCH/PUT /vehicles/1
    # PATCH/PUT /vehicles/1.json
    def update
      begin
        @vehicles = Vehicle.find(params[:id])
        @vehicles.update(
          name:params[:name],
          status:params[:status],
          mileage: params[:mileage],
          reg_number:params[:reg_number]
        )

        uri = URI("#{ENV['PROJECTS_SERVICE']}/vehicle_assignments")
        uri.query = URI.encode_www_form({'vehicle_id' => params[:id]})

        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Delete.new(uri.request_uri)

        response = http.request(request) # TODO handle errors

        unless params[:assigned_project].empty?
          params[:assigned_project].each do |assigned_project|
            logger.info(assigned_project)
            request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
            request.body = {vehicle_id: params[:id], project_id: assigned_project[:project_id], project_name: assigned_project[:project_name]}.to_json
            response = http.request(request)
          end
        end


        if @vehicles.save
          render json: {
            vehicles: @vehicles
          }, status: :ok
        else
          render json: {
            error: @vehicles.errors.full_messages.to_sentence
          }, status: :unprocessable_entity
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
         end
    end

    # DELETE /vehicles/1
    # DELETE /vehicles/1.json
    def destroy
      begin
        @vehicles = Vehicle.find(params[:id])
        @vehicles.destroy
        head :no_content
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicles = Vehicle.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end

    # Only allow a list of trusted parameters through.
    def vehicle_params
      params.fetch(:vehicle, {})
    end
  end
end