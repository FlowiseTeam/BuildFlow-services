module Api
  class VehiclesController < ApplicationController
    require 'uri'
    require 'net/http'
    before_action :set_vehicle, only: %i[ show update destroy ]

    # GET /vehicles
    def index
      begin
        @vehicles = Vehicle.all
        @vehicles_count = Vehicle.count

        if @vehicles_count.zero?
          render json: { vehicles: [] }, status: :ok
        else
          uri = URI("#{ENV['PROJECTS_SERVICE']}/vehicle_assignments")

          auth_header = request.headers['Authorization']

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri)
          request['Authorization'] = auth_header

          response = http.request(request)

          if response.is_a?(Net::HTTPSuccess)
            data = JSON.parse(response.body)
            vehicle_assignments_data = data['vehicle_assignments']
          else
            vehicle_assignments_data = [uri, puts(ENV['PROJECTS_SERVICE'])]
          end

          vehicles_with_assigned_projects = @vehicles.map do |vehicle|
            {
              _id: vehicle['_id'],
              created_at: vehicle['created_at'],
              updated_at: vehicle['updated_at'],
              name: vehicle['name'],
              status: vehicle['status'],
              mileage: vehicle['mileage'],
              reg_number: vehicle['reg_number'],
              rev_date: vehicle['rev_date'],
              assigned_project: vehicle_assignments_data.select { |assignment| assignment['vehicle_id'] == vehicle['_id'] },
              capacity: vehicle['capacity'],
            }
          end

          render json: { vehicles: vehicles_with_assigned_projects, vehicles_count: @vehicles_count }, status: :ok
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # GET /vehicles/1
    def show
      begin
        @vehicle = Vehicle.find(params[:id])
        begin
          uri = URI("#{ENV['PROJECTS_SERVICE']}/vehicle_assignments")
          uri.query = URI.encode_www_form({ 'vehicle_id' => params[:id] })

          auth_header = request.headers['Authorization']

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri)
          request['Authorization'] = auth_header

          response = http.request(request)

          if response.is_a?(Net::HTTPSuccess)
            data = JSON.parse(response.body)
            vehicle_assignments_data = data['vehicle_assignments']
          else
            vehicle_assignments_data = []
          end
        rescue StandardError => e
          vehicle_assignments_data = ['Błąd brak połączenia z serwisem']
        end
        @vehicle[:assigned_project] = vehicle_assignments_data

        render json: { vehicle: @vehicle }, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # POST /vehicles
    # POST /vehicles.json
    def create
      begin
        event_id = set_rev_date_event(params[:reg_number], params[:rev_date], params[:name])

        @vehicle = Vehicle.create(
          name: params[:name],
          status: params[:status],
          mileage: params[:mileage],
          reg_number: params[:reg_number],
          rev_date: params[:rev_date],
          capacity: params[:capacity],
          event_id: event_id
        )

        if @vehicle.save
          render json: { vehicles: @vehicle }, status: :created
        else
          render json: { error: @vehicle.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # PATCH/PUT /vehicles/1
    def update
      begin
        @vehicle = Vehicle.find(params[:id])
        @vehicle.update(
          name: params[:name],
          status: params[:status],
          mileage: params[:mileage],
          reg_number: params[:reg_number],
          rev_date: params[:rev_date],
          capacity: params[:capacity]
        )

        @vehicle[:assigned_project] = params[:assigned_project] || []

        auth_header = request.headers['Authorization']

        uri = URI("#{ENV['PROJECTS_SERVICE']}/vehicle_assignments")
        uri.query = URI.encode_www_form({ 'vehicle_id' => params[:id] })

        http = Net::HTTP.new(uri.host, uri.port)

        delete_request = Net::HTTP::Delete.new(uri.request_uri)
        delete_request['Authorization'] = auth_header
        http.request(delete_request)

        unless params[:assigned_project].nil? || params[:assigned_project].empty?
          vehicle_assignments_data = []
          params[:assigned_project].each do |assigned_project|
            logger.info(assigned_project)
            post_request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
            post_request['Authorization'] = auth_header
            post_request.body = { vehicle_id: params[:id], project_id: assigned_project[:project_id], project_name: assigned_project[:project_name] }.to_json

            response = http.request(post_request)
            if response.is_a?(Net::HTTPSuccess)
              data = JSON.parse(response.body)
              vehicle_assignments_data << data['vehicle_assignments']
            end
          end
          @vehicle[:assigned_project] = vehicle_assignments_data
        end

        if params[:status] == 'W serwisie'
          @vehicle[:status] = 'W serwisie'
        elsif params[:assigned_project].empty?
          @vehicle[:status] = 'Wolny'
        else
          @vehicle[:status] = 'W użyciu'
        end

        if params[:assigned_project].empty?
          @vehicle[:assigned_project] = []
        end

        set_rev_date_event(params[:reg_number], params[:rev_date], params[:name], @vehicle.event_id)

        if @vehicle.save
          render json: { vehicle: @vehicle }, status: :ok
        else
          render json: { error: @vehicle.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end

    # DELETE /vehicles/1
    def destroy
      begin
        @vehicle = Vehicle.find(params[:id])

        delete_event(@vehicle.event_id)

        @vehicle.destroy
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
      @vehicle = Vehicle.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end

    # Only allow a list of trusted parameters through.
    def vehicle_params
      params.fetch(:vehicle, {})
    end

    def set_rev_date_event(reg_number, rev_date, name, event_id=nil)
      date = Date.strptime(rev_date, '%Y-%m-%d')
      start_date = date.strftime('%Y-%m-%dT10:00:00')
      end_date = date.strftime('%Y-%m-%dT11:00:00')

      body = {
        "summary": "Przegląd pojazdu",
        "location": "Warsztat",
        "description": "Przegląd #{name} o numerach rejestracyjnych: #{reg_number}",
        "start": start_date,
        "end": end_date
      }.to_json

      base_uri = ENV['PROJECTS_SERVICE'].gsub('/projects', '')

      if event_id
        uri = URI("#{base_uri}/calendar/events/#{event_id}")
        event_request = Net::HTTP::Put.new(uri.request_uri, 'Content-Type' => 'application/json')
      else
        uri = URI("#{base_uri}/calendar/events")
        event_request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      end

      http = Net::HTTP.new(uri.host, uri.port)
      event_request['Authorization'] = request.headers['Authorization']
      event_request.body = body

      response = http.request(event_request)
      parsed_response = JSON.parse(response.body)
      parsed_response['id']
    end

    def delete_event(event_id)
      base_uri = ENV['PROJECTS_SERVICE'].gsub('/projects', '')
      uri = URI("#{base_uri}/calendar/events/#{event_id}")

      event_request = Net::HTTP::Delete.new(uri.request_uri, 'Content-Type' => 'application/json')
      event_request['Authorization'] = request.headers['Authorization']

      http = Net::HTTP.new(uri.host, uri.port)
      http.request(event_request)

    end
  end
end
