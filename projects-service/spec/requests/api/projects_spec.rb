require 'swagger_helper'

RSpec.describe 'api/projects', type: :request do

  path '/api/projects' do

    get('list projects') do
      tags 'Projects'
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

    post('create project') do
      tags 'Projects'
      consumes 'application/json'
      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          city: { type: :string },
          client: { type: :string },
          start_date: { type: :string, format: 'date' },
          end_date: { type: :string, format: 'date' },
          name: { type: :string },
          status: { type: :string },
          street: { type: :string },
          zipcode: { type: :string }
        },
        required: ['city', 'client', 'start_date', 'end_date', 'name', 'status', 'street', 'zipcode']
      }
      response(200, 'successful') do
        let(:project) { { city: 'City', client: 'Client', start_date: '2023-06-23', end_date: '2023-06-23', name: 'Project Name', status: 'Status', street: 'Street', zipcode: 'Zipcode' } }
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

  path '/api/projects/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show project') do
      tags 'Projects'
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

    delete('delete project') do
      tags 'Projects'
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

    put('update project') do
      tags 'Projects'
      consumes 'application/json'
      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          city: { type: :string },
          client: { type: :string },
          start_date: { type: :string, format: 'date' },
          end_date: { type: :string, format: 'date' },
          name: { type: :string },
          status: { type: :string },
          street: { type: :string },
          zipcode: { type: :string }
        },
        required: ['city', 'client', 'start_date', 'end_date', 'name', 'status', 'street', 'zipcode']
      }
      response(200, 'successful') do
        let(:id) { '123' }
        let(:project) { { city: 'City', client: 'Client', start_date: '2023-06-23', end_date: '2023-06-23', name: 'Project Name', status: 'Status', street: 'Street', zipcode: 'Zipcode' } }
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
