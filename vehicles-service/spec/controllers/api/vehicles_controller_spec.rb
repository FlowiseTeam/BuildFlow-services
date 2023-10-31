require 'rails_helper'

RSpec.describe Api::VehiclesController, type: :controller do

  # CREATE
  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:vehicle) }
    let(:invalid_attributes) do
      {
        name: ""
      }
    end

    context 'with valid attributes' do
      it 'creates a new vehicles and returns it' do
        request.headers['CONTENT_TYPE'] = 'application/json'
        request.headers['ACCEPT'] = 'application/json'
        expect {
          post :create, body: valid_attributes.to_json
        }.to change(Vehicle, :count).by(1)

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(parsed_response["vehicles"]["name"]).to eq(valid_attributes[:name])
        expect(parsed_response["vehicles"]["status"]).to eq(valid_attributes[:status])
        expect(parsed_response["vehicles"]["mileage"]).to eq(valid_attributes[:mileage])
        expect(parsed_response["vehicles"]["reg_number"]).to eq(valid_attributes[:reg_number])
      end
      after do
        vehicle_id = JSON.parse(response.body)["vehicles"]["_id"]
        Vehicle.find(vehicle_id).destroy
      end
    end


    context 'with invalid attributes' do
      it 'does not create the vehicle and returns an error message' do
        request.headers['CONTENT_TYPE'] = 'application/json'
        request.headers['ACCEPT'] = 'application/json'

        post :create, body: invalid_attributes.to_json

        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["error"]).to be_present
      end
    end

    context 'when another error occurs' do
      before do
        allow_any_instance_of(Vehicle).to receive(:save).and_raise(StandardError.new)
      end

      it 'returns internal server error' do
        post :create, params: { vehicle: valid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:internal_server_error)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

  # SHOW
  describe 'GET #show' do
    let(:vehicle) { create(:vehicle) }
    after do
      vehicle.destroy
    end

    context 'when the vehicle exists' do
      before { get :show, params: { id: vehicle.id } }

      it 'returns the vehicle details' do
        parsed_response = JSON.parse(response.body)
        puts parsed_response

        expect(response).to have_http_status(:ok)
        expect(parsed_response["vehicle"]["_id"].to_s).to eq(vehicle.id.to_s)
        expect(parsed_response["vehicle"]["name"].to_s).to eq(vehicle.name.to_s)
      end
    end

    context 'when the vehicle does not exist' do
      before { get :show, params: { id: BSON::ObjectId.new.to_s } }

      it 'returns a not found error' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end

    context 'when a standard error occurs' do
      before do
        allow(Vehicle).to receive(:find).and_raise(StandardError)
        get :show, params: { id: vehicle.id }
      end

      it 'returns an internal server error' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:internal_server_error)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

  # DESTROY
  describe 'DELETE #destroy' do
    let(:vehicle) { create(:vehicle) }

    context 'when the vehicle exists' do
      it 'deletes the vehicle and associated records' do
        delete :destroy, params: { id: vehicle.id }
        expect { vehicle.reload }.to raise_error(Mongoid::Errors::DocumentNotFound)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the vehicle does not exist' do
      it 'returns a not found error' do
        delete :destroy, params: { id: BSON::ObjectId.new.to_s }

        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end
  end

  # INDEX
  describe 'GET #index' do
    context 'when there are no vehicles' do
      before { get :index }

      it 'returns an empty array' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response["message"]).to eq('Nie znaleziono')
      end
    end

    context 'when there are vehicles' do
      let!(:vehicle1) { create(:vehicle) }
      let!(:vehicle2) { create(:vehicle) }
      let!(:vehicle3) { create(:vehicle) }

      before { get :index }
      after do
        vehicle1.destroy
        vehicle2.destroy
        vehicle3.destroy
      end

      it 'returns all vehicles' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response["vehicles"].size).to eq(3)

        parsed_response["vehicles"].find { |p| p["_id"] == vehicle1.id.to_s }
        parsed_response["vehicles"].find { |p| p["_id"] == vehicle2.id.to_s }
        parsed_response["vehicles"].find { |p| p["_id"] == vehicle3.id.to_s }
      end

      it 'returns the correct vehicles count' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["vehicles_count"]).to eq(3)
      end
    end

    context 'when a standard error occurs' do
      before do
        allow(Vehicle).to receive(:all).and_raise(StandardError)
        get :index
      end

      it 'returns an internal server error' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:internal_server_error)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

  # UPDATE
  describe 'PUT #update' do
    let(:vehicle) { create(:vehicle) }
    let(:valid_attributes) do
      {
        name: 'Excavator',
        status: 'busy',
        mileage: 207022,
        reg_number: 'WLI20655',
        rev_date: Date.tomorrow + 5.month,
        assigned_project: [],
        capacity: 2004,
      }
    end

      # before do
      #   project_service_url = "#{ENV['PROJECTS_SERVICE']}/vehicle_assignments"
      #
      #   stub_request(:delete, "#{project_service_url}?vehicle_id=#{vehicle.id}")
      #     .to_return(status: 200, body: "", headers: {})
      #
      #   valid_attributes[:assigned_project].each do |project|
      #     stub_request(:post, project_service_url)
      #       .with(body: { vehicle_id: vehicle.id, project_id: project[:project_id], project_name: project[:project_name] }.to_json)
      #       .to_return(status: 200, body: "", headers: {})
      #   end
      # end

    after do
      vehicle.destroy
    end

    context 'with valid attributes' do
      it 'updates the vehicle' do
        put :update, params: valid_attributes.merge(id: vehicle.id), format: :json
        parsed_response = JSON.parse(response.body)
        puts parsed_response
        vehicle.reload

        expect(vehicle.name).to eq(valid_attributes[:name])
        expect(vehicle.mileage).to eq(valid_attributes[:mileage])
        expect(vehicle.status).to eq(valid_attributes[:status])
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        {
          name: '',
        }
      end

      it 'does not update the vehicle and returns unprocessable entity' do
        put :update, params: { id: vehicle.id }.merge(invalid_attributes)
        vehicle.reload

        expect(vehicle.name).not_to eq('')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the vehicles does not exist' do
      it 'returns a not found error' do
        put :update, params: { id: BSON::ObjectId.new.to_s }.merge(valid_attributes)

        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end

    context 'when a standard error occurs' do
      before do
        allow_any_instance_of(Vehicle).to receive(:update).and_raise(StandardError)
      end

      it 'returns an internal server error' do
        put :update, params: valid_attributes.merge(id: vehicle.id), format: :json
        expect(response).to have_http_status(:internal_server_error)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

end


