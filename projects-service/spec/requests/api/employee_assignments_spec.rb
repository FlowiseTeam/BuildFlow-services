require 'swagger_helper'

RSpec.describe 'employee_assignments API', type: :request do

  path '/api/projects/employee_assignments' do

    get('show employee_assignment') do
      tags 'Employee assigments'
      parameter name: 'employee_id', in: :query, type: :string, description: 'Employee ID'
      parameter name: 'project_id', in: :query, type: :string, description: 'Project ID'
      response(200, 'successful') do
        let(:employee_id) { '1' }
        let(:project_id) { '1' }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    post('create employee_assignment') do
      tags 'Employee assigments'
      consumes 'application/json'
      parameter name: :employee_assignment, in: :body, schema: {
        type: :object,
        properties: {
          project_id: { type: :integer },
          employee_id: { type: :integer },
          project_name: { type: :string },
        },
        required: ['project_id', 'employee_id', 'project_name']
      }

      response(200, 'successful') do
        let(:employee_assignment) { { project_id: '1', employee_id: '123', project_name: 'Project Name' } }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    delete('delete employee_assignment') do
      tags 'Employee assigments'
      parameter name: 'id', in: :query, type: :string, description: 'Employee Assignment ID'
      response(200, 'successful') do
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
    end
  end
end
