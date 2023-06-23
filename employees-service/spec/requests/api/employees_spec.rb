require 'swagger_helper'

RSpec.describe 'api/employees', type: :request do

  path '/api/employees' do

    get('list employees') do
      tags 'Employees'
      response(200, 'successful') do

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

    post('create employee') do
      tags 'Employees'
      consumes 'application/json'
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
        let(:employee) { { first_name: 'John', last_name: 'Doe', role: 'Engineer', status: 'Active', qualifications: 'MSc' } }
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

  path '/api/employees/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show employee') do
      tags 'Employees'
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

    delete('delete employee') do
      tags 'Employees'
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
    end

    put('update employee') do
      tags 'Employees'
      consumes 'application/json'
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
      response(200, 'successful') do
        let(:id) { '123' }
        let(:employee) { { first_name: 'John', last_name: 'Doe', role: 'Engineer', status: 'Active', qualifications: 'MSc' } }
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
