require 'rails_helper'

RSpec.describe Api::ProjectsController, type: :controller do

  # CREATE
  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:project) }
    let(:invalid_attributes) do
      {
        city: "",
      }
    end

    context 'with valid attributes' do
      it 'creates a new project and returns it' do
        request.headers['CONTENT_TYPE'] = 'application/json'
        request.headers['ACCEPT'] = 'application/json'
        expect {
          post :create, body: valid_attributes.to_json
        }.to change(Project, :count).by(1)

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(parsed_response["project"]["name"]).to eq(valid_attributes[:name])
      end
      after do
        project_id = JSON.parse(response.body)["project"]["_id"]
        Project.find(project_id)&.destroy
      end
    end


    context 'with invalid attributes' do
      it 'does not create the project and returns an error message' do
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
        allow_any_instance_of(Project).to receive(:save).and_raise(StandardError.new)
      end

      it 'returns internal server error' do
        post :create, params: { project: valid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:internal_server_error)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end

  # SHOW
  describe 'GET #show' do
    let(:project) { create(:project) }
    after do
      project.destroy
    end

    context 'when the project exists' do
      before { get :show, params: { id: project.id } }

      it 'returns the project details' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response["projects"]["_id"].to_s).to eq(project.id.to_s) # Convert BSON::ObjectId to string
      end

    end

    context 'when the project does not exist' do
      before { get :show, params: { id: BSON::ObjectId.new.to_s } } # Use a new BSON ObjectId

      it 'returns a not found error' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end

    context 'when a standard error occurs' do
      before do
        allow(Project).to receive(:find).and_raise(StandardError)
        get :show, params: { id: project.id }
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
    context 'when there are no projects' do
      before { get :index }

      it 'returns an empty array' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response["projects"]).to eq([])
      end
    end

    context 'when there are projects' do
      let!(:project1) { create(:project) }
      let!(:project2) { create(:project) }

      before { get :index }
      after do
        project1.destroy
        project2.destroy
      end
      it 'returns all projects with their associated employee and vehicle assignments' do
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response["projects"].size).to eq(2)

        parsed_response["projects"].find { |p| p["_id"] == project1.id.to_s }
        parsed_response["projects"].find { |p| p["_id"] == project2.id.to_s }
      end

      it 'returns the correct project count' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["project_count"]).to eq(2)
      end
    end

    context 'when a standard error occurs' do
      before do
        allow(Project).to receive(:all).and_raise(StandardError)
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
    let(:project) { create(:project) }

    context 'when the project exists' do
      it 'deletes the project and associated records' do
        delete :destroy, params: { id: project.id }
        expect { project.reload }.to raise_error(Mongoid::Errors::DocumentNotFound)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the project does not exist' do
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
    let(:project) { create(:project) }
    let(:valid_attributes) do
      {
        city: 'Updated City',
        client: 'Updated Client',
        start_date: Date.tomorrow,
        end_date: Date.tomorrow + 1.week,
        name: 'Updated Project Name',
        status: 'updated',
        street: 'Updated Street',
        zipcode: '99-999',
        employees: [],
        vehicles: []
      }
    end

    after do
      project.destroy
    end

    context 'with valid attributes' do
      it 'updates the project' do
        put :update, params: valid_attributes.merge(id: project.id), format: :json
        project.reload

        expect(project.city).to eq(valid_attributes[:city])
        expect(project.client).to eq(valid_attributes[:client])
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        {
          name: '',
        }
      end

      it 'does not update the project and returns unprocessable entity' do
        put :update, params: { id: project.id }.merge(invalid_attributes)
        project.reload

        expect(project.name).not_to eq('')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        put :update, params: { id: BSON::ObjectId.new.to_s }.merge(valid_attributes)

        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Nie znaleziono rekordu')
      end
    end

    context 'when a standard error occurs' do
      before do
        allow_any_instance_of(Project).to receive(:update).and_raise(StandardError)
      end

      it 'returns an internal server error' do
        put :update, params: valid_attributes.merge(id: project.id), format: :json
        expect(response).to have_http_status(:internal_server_error)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Wystąpił błąd serwera')
      end
    end
  end
end

