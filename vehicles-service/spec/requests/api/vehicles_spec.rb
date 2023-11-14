require 'swagger_helper'

RSpec.describe 'api/vehicles', type: :request do

  path '/api/vehicles' do

    get('list vehicles') do
      tags 'Vehicles'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 vehicles: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :string },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' },
                       name: { type: :string },
                       status: { type: :string },
                       mileage: { type: :integer },
                       reg_number: { type: :string },
                       rev_date: { type: :string, format: 'date-time' },
                       assigned_project: { type: :array },
                       capacity: { type: :integer }
                     },
                   }
                 },
                 vehicles_count: { type: :integer }
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

      response(404, 'not found') do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: ['message'],
               example: {
                 message: 'Nie znaleziono rekordu'
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


    post('create vehicle') do
      tags 'Vehicles'

      consumes 'application/json'
      produces 'application/json'

      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          status: { type: :string },
          mileage: { type: :integer },
          reg_number: { type: :string }
        },
        required: ['name', 'status', 'mileage', 'reg_number']
      }

      response(201, 'created') do
        let(:vehicle) { { name: 'Example Vehicle', status: 'active', mileage: 5000, reg_number: 'XYZ123' } }

        schema type: :object,
               properties: {
                 vehicles: {
                   type: :object,
                   properties: {
                     name: { type: :string },
                     status: { type: :string },
                     mileage: { type: :integer },
                     reg_number: { type: :string }
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

      response(422, 'unprocessable entity') do
        let(:vehicle) { { name: '', status: '', mileage: nil, reg_number: '' } }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: { error: 'Validation failed: Name cant be blank, Status cant be blank, Mileage cant be blank, Reg number cant be blank' }
            }
          }
        end
        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Nie znaleziono'
               }

        run_test!
      end
    end
  end

  path '/api/vehicles/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show vehicle') do
      tags 'Vehicles'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'Vehicle ID'

      response(200, 'successful') do
        let(:id) { 'existing_vehicle_id' }

        schema type: :object,
               properties: {
                 vehicle: {
                   type: :object,
                   properties: {
                     _id: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' },
                     name: { type: :string },
                     status: { type: :string },
                     mileage: { type: :integer },
                     reg_number: { type: :string },
                     rev_date: { type: :string, format: 'date-time' },
                     assigned_project: { type: :array },
                     capacity: { type: :integer }
                   }
                 }
               }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: { vehicle: { _id: 'existing_vehicle_id', name: 'Vehicle 1', status: 'active'} }
            }
          }
        end
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 'non_existing_vehicle_id' }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Nie znaleziono'
               }

        run_test!
      end

      response(500, 'internal server error') do
        let(:id) { 'causing_error_vehicle_id' }

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

    put('update vehicle') do
      tags 'Vehicles'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'Vehicle ID'
      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          status: { type: :string },
          mileage: { type: :integer },
          reg_number: { type: :string },
          assigned_project: {
            type: :array,
            items: {
              type: :object,
              properties: {
                project_id: { type: :string },
                project_name: { type: :string }
              }
            }
          }
        },
        required: ['name', 'status', 'mileage', 'reg_number']
      }

      response(200, 'successful') do
        let(:id) { 'existing_vehicle_id' }
        let(:vehicle) { { name: 'Updated Vehicle', status: 'active', mileage: 6000, reg_number: 'XYZ456', assigned_project: [] } }

        schema type: :object,
               properties: {
                 vehicles: {
                   type: :object,
                   properties: {
                     name: { type: :string },
                     status: { type: :string },
                     mileage: { type: :integer },
                     reg_number: { type: :string },
                     assigned_project: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           project_id: { type: :string },
                           project_name: { type: :string }
                         }
                       }
                     }
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

      response(404, 'not found') do
        let(:id) { 'non_existing_vehicle_id' }
        let(:vehicle) { { name: 'Vehicle', status: 'active', mileage: 6000, reg_number: 'XYZ456', assigned_project: [] } }

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

      response(422, 'unprocessable entity') do
        let(:id) { 'existing_vehicle_id' }
        let(:vehicle) { { name: '', status: '', mileage: nil, reg_number: '', assigned_project: [] } }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        run_test!
      end

      response(500, 'internal server error') do
        let(:id) { 'causing_error_vehicle_id' }

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

    delete('delete vehicle') do
      tags 'Vehicles'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'Vehicle ID'

      response(204, 'no content') do
        let(:id) { 'existing_vehicle_id' }

        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end

      response(404, 'not found') do
        let(:id) { 'non_existing_vehicle_id' }

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
        let(:id) { 'causing_error_vehicle_id' } # Symulowanie warunku błędu

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
