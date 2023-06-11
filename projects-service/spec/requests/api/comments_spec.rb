require 'swagger_helper'

RSpec.describe 'api/comments', type: :request do

  path '/api/projects/{project_id}/comments' do
    # You'll want to customize the parameter types...
    parameter name: 'project_id', in: :path, type: :string, description: 'project_id'

    get('list comments') do
      tags 'Comments'
      response(200, 'successful') do
        let(:project_id) { '123' }

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

    post('create comment') do
      tags 'Comments'
      response(200, 'successful') do
        let(:project_id) { '123' }

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

  path '/api/projects/{project_id}/comments/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'project_id', in: :path, type: :string, description: 'project_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show comment') do
      tags 'Comments'
      response(200, 'successful') do
        let(:project_id) { '123' }
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

    put('update comment') do
      tags 'Comments'
      response(200, 'successful') do
        let(:project_id) { '123' }
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

    delete('delete comment') do
      tags 'Comments'
      response(200, 'successful') do
        let(:project_id) { '123' }
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
