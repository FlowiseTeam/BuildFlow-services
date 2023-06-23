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
      consumes 'application/json'
      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          message: { type: :string },
          status: { type: :string },
          images: { type: :array, items: { type: :string } },
        },
        required: ['message', 'status']
      }

      response(200, 'successful') do
        let(:project_id) { '123' }
        let(:comment) { { message: 'Example message', status: 'active', images: ['image1.png', 'image2.png'] } }

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

    path '/api/projects/{project_id}/comments/{id}' do
      # You'll want to customize the parameter types...
      parameter name: 'project_id', in: :path, type: :string, description: 'project_id'
      parameter name: 'id', in: :path, type: :string, description: 'id'

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
end
