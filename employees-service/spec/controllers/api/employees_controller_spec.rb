require 'rails_helper'

RSpec.describe Api::EmployeesController, type: :controller do

  # CREATE
  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:employee) }
    let(:invalid_attributes) do
      {
        first_name: "",
      }
    end

    context 'with valid attributes' do
      it 'creates a new employee and returns it' do
        request.headers['CONTENT_TYPE'] = 'application/json'
        request.headers['ACCEPT'] = 'application/json'
        expect {
          post :create, body: valid_attributes.to_json
        }.to change(Employee, :count).by(1)
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(parsed_response["employees"]["first_name"]).to eq(valid_attributes[:first_name])
      end
      after do
        employee_id = JSON.parse(response.body)["employees"]["_id"]
        Employee.find(employee_id)&.destroy
      end
    end

    context 'with invalid attributes' do
      it 'does not create the employee and returns an error message' do
        request.headers['CONTENT_TYPE'] = 'application/json'
        request.headers['ACCEPT'] = 'application/json'

         post :create, body: invalid_attributes.to_json

        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["error"]).to be_present  # Adjust for your specific error message
      end
    end

    context 'when another error occurs' do
      before do
        allow_any_instance_of(Employee).to receive(:save).and_raise(StandardError.new)
      end

      it 'returns internal server error' do
        post :create, params: { employee: valid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:internal_server_error)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

  #SHOW
  describe 'GET #show' do
    let(:employee) { create(:employee) }
    after do
      employee.destroy
    end

    context 'when the employees exists' do
      before { get :show, params: { id: employee.id } }

      it 'returns the employees details' do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["employee"]["_id"].to_s).to eq(employee.id.to_s) # Convert BSON::ObjectId to string
      end

    end

    context 'when the employees does not exist' do
      before { get :show, params: { id: BSON::ObjectId.new.to_s } } # Use a new BSON ObjectId

      it 'returns a not found error' do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end

    context 'when a standard error occurs' do
      before do
        allow(Employee).to receive(:find).and_raise(StandardError)
        get :show, params: { id: employee.id }
      end

      it 'returns an internal server error' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:internal_server_error)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

  # INDEX
  describe 'GET #index' do
    context 'when there are no employees' do
      before { get :index }

      it 'returns an empty array' do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response["error"]).to eq('Brak rekordów')
      end
    end

    context 'when there are employees' do
      let!(:employee1) { create(:employee) }
      let!(:employee2) { create(:employee) }

      before { get :index }
      after do
        employee1.destroy
        employee2.destroy
      end
      it 'returns all employees' do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["employees"].size).to eq(2)

        parsed_response["employees"].find { |p| p["_id"] == employee1.id.to_s }
        parsed_response["employees"].find { |p| p["_id"] == employee2.id.to_s }
      end

      it 'returns the correct project count' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["employees_count"]).to eq(2)
      end
    end

    context 'when a standard error occurs' do
      before do
        allow(Employee).to receive(:all).and_raise(StandardError)
        get :index
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
    let(:employee) { create(:employee) }

    context 'when the employee exists' do
      it 'deletes the employee and associated records' do
        delete :destroy, params: { id: employee.id }
        expect { employee.reload }.to raise_error(Mongoid::Errors::DocumentNotFound)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the employee does not exist' do
      it 'returns a not found error' do
        delete :destroy, params: { id: BSON::ObjectId.new.to_s }  # Use a new BSON ObjectId

        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end
  end

  # UPDATE
  describe 'PUT #update' do
    let(:employee) { create(:employee) }
    let(:valid_attributes) do
      {
        first_name: 'Updated first_name',
        last_name: 'Updated last_name',
        role: '',
        status: 'updated',
        qualifications: [],
        assigned_project: []
      }
    end

    after do
      employee.destroy
    end

    context 'with valid attributes' do
      it 'updates the employee' do
        put :update, params: valid_attributes.merge(id: employee.id), format: :json
        employee.reload

        expect(employee.first_name).to eq(valid_attributes[:first_name])
        expect(employee.last_name).to eq(valid_attributes[:last_name])
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        {
          name: '',
        }
      end

      it 'does not update the employee and returns unprocessable entity' do
        put :update, params: { id: employee.id }.merge(invalid_attributes)
        employee.reload

        expect(employee.first_name).not_to eq('')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the employee does not exist' do
      it 'returns a not found error' do
        put :update, params: { id: BSON::ObjectId.new.to_s }.merge(valid_attributes)

        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end

    context 'when a standard error occurs' do
      before do
        allow_any_instance_of(Employee).to receive(:update).and_raise(StandardError)
      end

      it 'returns an internal server error' do
        put :update, params: valid_attributes.merge(id: employee.id), format: :json
        expect(response).to have_http_status(:internal_server_error)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end
end