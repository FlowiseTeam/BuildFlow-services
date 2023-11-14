require 'swagger_helper'

RSpec.describe 'api/employees', type: :request do

  path '/api/employees' do

    get('list employees') do
      tags 'Employees'
      description 'Retrieves a list of all employees along with their assigned projects. Returns detailed information for each employee.'
      produces 'application/json'
      response(200, 'successful') do
        description 'A list of employees with their details and assigned projects'
        schema type: :object,
               properties: {
                 employees: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :string },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' },
                       first_name: { type: :string },
                       last_name: { type: :string },
                       role: { type: :string },
                       qualifications: { type: :array, items: { type: :string } },
                       assigned_project: {
                         type: :array,
                         items: { type: :object }
                       },
                       status: { type: :string }
                     },
                     required: ['_id', 'created_at', 'updated_at', 'first_name', 'last_name', 'role', 'status']
                   }
                 },
                 employees_count: { type: :integer }
               },
               required: ['employees', 'employees_count']

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


    post('create employee') do
      tags 'Employees'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :employee, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          role: { type: :string },
          status: { type: :string },
          qualifications: { type: :array, items: { type: :string } },
        },
        required: ['first_name', 'last_name', 'role', 'status', 'qualifications']
      }
      response(201, 'created') do
        schema type: :object,
               properties: {
                 employee: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     role: { type: :string },
                     status: { type: :string },
                     qualifications: { type: :array, items: { type: :string } },
                   }
                 }
               }
        let(:employee) { { first_name: 'John', last_name: 'Doe', role: 'Engineer', status: 'Active', qualifications: ['MSc'] } }
        run_test!
      end
      response 422, 'Unprocessable Entity' do
        schema type: :object,
               properties: {
                 error: { type: :string }
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

  path '/api/employees/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show employee') do
      tags 'Employees'
      produces 'application/json'
      consumes 'application/json'
      response(200, 'successful') do
        schema type: :object,
               properties: {
                 employee: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     name: { type: :string },
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
               },
               required: ['employee']
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
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: ['message'],
               example: {
                 error: 'Nie znaleziono'
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

    delete('delete employee') do
      tags 'Employees'
      produces 'application/json'
      response(204, 'deleted') do
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
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: ['message'],
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

    put('update employee') do
      tags 'Employees'
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string, required: true, description: 'Employee ID'
      parameter name: :employee, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          role: { type: :string },
          status: { type: :string },
          qualifications: { type: :array, items: { type: :string } },
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
        required: ['first_name', 'last_name', 'role', 'status', 'qualifications']
      }
      response 200, 'successful' do
        schema type: :object,
               properties: {
                 employee: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     role: { type: :string },
                     status: { type: :string },
                     qualifications: { type: :array, items: { type: :string } },
                   }
                 }
               }
        run_test!
      end

      response(404, 'not found') do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: ['message'],
               example: {
                 error: 'Nie znaleziono rekordu'
               }

        run_test!
      end

      response 422, 'unprocessable entity' do
        let(:employee) { { first_name: '' } }
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
