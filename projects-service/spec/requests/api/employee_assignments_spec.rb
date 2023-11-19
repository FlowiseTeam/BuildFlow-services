require 'swagger_helper'

RSpec.describe 'api/employee_assignments', type: :request do

  path '/api/projects/employee_assignments' do

    get('show employee_assignment') do
      tags 'EmployeeAssignments'
      produces 'application/json'
      parameter name: :project_id, in: :query, type: :string, required: false, description: 'ID of the project'
      parameter name: :employee_id, in: :query, type: :string, required: false, description: 'ID of the employee'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 employee_assignments: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :integer },
                       created_at: { type: :string, format: 'date-time' },
                       employee_id: { type: :integer },
                       project_id: { type: :integer },
                       project_name: { type: :string },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: ['_id', 'created_at', 'employee_id', 'project_id', 'project_name', 'updated_at']
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
                 error: 'Missing parameter: either project_id or employee_id must be provided'
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


    post('create employee_assignment') do
      tags 'EmployeeAssignments'
      produces 'application/json'
      parameter name: :project_id, in: :query, type: :integer, required: true, description: 'ID of the project'
      parameter name: :employee_id, in: :query, type: :integer, required: true, description: 'ID of the employee'
      parameter name: :project_name, in: :query, type: :string, required: true, description: 'Name of the project'

      response(201, 'created') do
        schema type: :object,
               properties: {
                 employee_assignments: {
                   type: :object,
                   properties: {
                     _id: { type: :integer },
                     project_id: { type: :integer },
                     employee_id: { type: :integer },
                     project_name: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   },
                   required: ['_id', 'project_id', 'employee_id', 'project_name', 'created_at', 'updated_at']
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


    delete('delete employee_assignment') do
      tags 'EmployeeAssignments'
      produces 'application/json'
      parameter name: :project_id, in: :query, type: :integer, required: false, description: 'ID of the project'
      parameter name: :employee_id, in: :query, type: :integer, required: false, description: 'ID of the employee'

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
                 error: 'Missing parameter: either project_id or employee_id must be provided'
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
