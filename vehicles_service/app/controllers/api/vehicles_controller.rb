module Api
class VehiclesController < ApplicationController
  before_action :set_vehicle, only: %i[ show update destroy ]

  # GET /vehicles
  # GET /vehicles.json
  def index
    @vehicles = Vehicle.all
    render json: @vehicles
  end

  # GET /vehicles/1
  # GET /vehicles/1.json
  def show
    @vehicle = Vehicle.find(params[:id])
    render json: @vehicle
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
    @vehicle = Vehicle.find(params[:id])
    if @vehicle.update(
      name:params[:name],
      status:params[:status],
      mileage: params[:mileage],
      reg_number:params[:reg_number]
    )
      render json: @vehicle
    else
      render json: @vehicle.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  # DELETE /vehicles/1
  # DELETE /vehicles/1.json
  def destroy
    begin
      @vehicle = Vehicle.find(params[:id])
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
end
end
