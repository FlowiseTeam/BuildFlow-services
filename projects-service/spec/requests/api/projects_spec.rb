require 'swagger_helper'

RSpec.describe 'api/projects', type: :request do

  path '/api/projects' do

    get('list projects') do
      tags 'Projects'
      produces 'application/json'
      response(200, 'successful') do
        schema type: :object,
               properties: {
                 projects: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :integer },
                       employees: {
                         type: :array,
                         items: { type: :integer }
                       },
                       subcontractors: {
                         type: :array,
                         items: { type: :integer }
                       },
                       city: { type: :string },
                       client: { type: :string },
                       start_date: { type: :string, format: 'date-time' },
                       end_date: { type: :string, format: 'date-time' },
                       name: { type: :string },
                       status: { type: :string },
                       street: { type: :string },
                       zipcode: { type: :string },
                       updated_at: { type: :string, format: 'date-time' },
                       created_at: { type: :string, format: 'date-time' },
                       vehicles: {
                         type: :array,
                         items: { type: :integer }
                       }
                     }
                   }
                 },
                 project_count: { type: :integer }
               },
               required: ['projects', 'project_count']

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

    post('create project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          city: { type: :string },
          client: { type: :string },
          start_date: { type: :string, format: 'date-time' },
          end_date: { type: :string, format: 'date-time' },
          name: { type: :string },
          status: { type: :string },
          street: { type: :string },
          zipcode: { type: :string }
        },
        required: ['city', 'client', 'start_date', 'end_date', 'name', 'status', 'street', 'zipcode']
      }

      response(201, 'successful') do
        schema type: :object,
               properties: {
                 project: {
                   type: :object,
                   properties: {
                     _id: { type: :integer },
                     city: { type: :string },
                     client: { type: :string },
                     start_date: { type: :string, format: 'date-time' },
                     end_date: { type: :string, format: 'date-time' },
                     name: { type: :string },
                     status: { type: :string },
                     street: { type: :string },
                     zipcode: { type: :string },
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
        let(:expected_error) { { error: 'Validation failed: [Error message]' } }
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

  path '/api/projects/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show project') do
      tags 'Projects'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string, description: 'ID of the project to retrieve'

      response(200, 'successful') do
        let(:id) { '123' }

        schema type: :object,
               properties: {
                 projects: {
                   type: :object,
                   properties: {
                     _id: { type: :integer },
                     city: { type: :string },
                     client: { type: :string },
                     start_date: { type: :string, format: 'date-time' },
                     end_date: { type: :string, format: 'date-time' },
                     name: { type: :string },
                     status: { type: :string },
                     street: { type: :string },
                     zipcode: { type: :string },
                     updated_at: { type: :string, format: 'date-time' },
                     created_at: { type: :string, format: 'date-time' },
                     employees: {
                       type: :array,
                       items: { type: :integer }
                     },
                     vehicles: {
                       type: :array,
                       items: { type: :integer }
                     },
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


    delete('delete project') do
      tags 'Projects'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string, description: 'ID of the project to delete'

      response(204, 'no content') do
        let(:id) { '123' }

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


    put('update project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string, description: 'ID of the project to update'
      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          city: { type: :string },
          client: { type: :string },
          start_date: { type: :string, format: 'date-time' },
          end_date: { type: :string, format: 'date-time' },
          name: { type: :string },
          status: { type: :string },
          street: { type: :string },
          zipcode: { type: :string },
          employees: {
            type: :array,
            items: { type: :integer }
          },
          vehicles: {
            type: :array,
            items: { type: :integer }
          },
          subcontractors: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                email: { type: :string },
                address: { type: :string },
                phone: { type: :string }
              }
            }
          }
        },
        required: ['city', 'client', 'start_date', 'end_date', 'name', 'status', 'street', 'zipcode']
      }

      response(200, 'successful') do
        let(:id) { '123' }

        schema type: :object,
               properties: {
                 projects: {
                   type: :object,
                   properties: {
                     _id: { type: :integer },
                     city: { type: :string },
                     client: { type: :string },
                     start_date: { type: :string, format: 'date-time' },
                     end_date: { type: :string, format: 'date-time' },
                     name: { type: :string },
                     status: { type: :string },
                     street: { type: :string },
                     zipcode: { type: :string },
                     employees: {
                       type: :array,
                       items: { type: :integer }
                     },
                     vehicles: {
                       type: :array,
                       items: { type: :integer }
                     },
                     subcontractors: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           name: { type: :string },
                           email: { type: :string },
                           address: { type: :string },
                           phone: { type: :string }
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

      response(422, 'unprocessable entity') do
        let(:expected_error) { { error: 'Validation failed: [Error message]' } }
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

  end
end
