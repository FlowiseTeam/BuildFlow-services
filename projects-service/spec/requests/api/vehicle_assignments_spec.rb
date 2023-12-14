require 'swagger_helper'

RSpec.describe 'api/vehicle_assignments', type: :request do

  path '/api/projects/vehicle_assignments' do

    get('show vehicle_assignment') do
      tags 'VehicleAssignments'
      produces 'application/json'
      parameter name: :project_id, in: :query, type: :integer, required: false, description: 'ID of the project'
      parameter name: :vehicle_id, in: :query, type: :integer, required: false, description: 'ID of the vehicle'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 vehicle_assignments: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :integer },
                       created_at: { type: :string, format: 'date-time' },
                       project_id: { type: :integer },
                       project_name: { type: :string },
                       updated_at: { type: :string, format: 'date-time' },
                       vehicle_id: { type: :integer }
                     },
                     required: ['_id', 'created_at', 'project_id', 'project_name', 'updated_at', 'vehicle_id']
                   }
                 }
               }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(400, 'bad request') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Missing parameter: either project_id or vehicle_id must be provided'
               }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 'non_existing_project_id' }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Nie znaleziono rekordu'
               }

        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Wystąpił błąd serwera'
               }
        run_test!
      end

    end


    post('create vehicle_assignment') do
      tags 'VehicleAssignments'
      produces 'application/json'
      parameter name: :project_id, in: :query, type: :integer, required: true, description: 'ID of the project'
      parameter name: :vehicle_id, in: :query, type: :integer, required: true, description: 'ID of the vehicle'
      parameter name: :project_name, in: :query, type: :string, required: true, description: 'Name of the project'

      response(201, 'created') do
        schema type: :object,
               properties: {
                 vehicle_assignments: {
                   type: :object,
                   properties: {
                     _id: { type: :integer },
                     created_at: { type: :string, format: 'date-time' },
                     project_id: { type: :integer },
                     project_name: { type: :string },
                     updated_at: { type: :string, format: 'date-time' },
                     vehicle_id: { type: :integer }
                   },
                   required: ['_id', 'project_id', 'vehicle_id', 'project_name']
                 }
               }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(422, 'unprocessable entity') do
        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Wystąpił błąd serwera'
               }
        run_test!
      end
    end


    delete('delete vehicle_assignment') do
      tags 'VehicleAssignments'
      produces 'application/json'
      parameter name: :project_id, in: :query, type: :integer, required: false, description: 'ID of the project'
      parameter name: :vehicle_id, in: :query, type: :integer, required: false, description: 'ID of the vehicle'

      response(204, 'no content') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(400, 'bad request') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Missing parameter: either project_id or vehicle_id must be provided'
               }
        run_test!
      end

      response(404, 'not found') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Nie znaleziono rekordu'
               }

        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Wystąpił błąd serwera'
               }
        run_test!
      end
    end

  end
end
