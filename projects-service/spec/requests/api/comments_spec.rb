require 'swagger_helper'

RSpec.describe 'api/comments', type: :request do

  path '/api/projects/comments/latest' do

    get('latest comment') do
      tags 'Comments'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   _id: { type: :integer },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' },
                   images: {
                     type: :array,
                     items: { type: :string }
                   },
                   message: { type: :string },
                   project_id: { type: :integer },
                   status: { type: :string }
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
    end

  end

  path '/api/projects/{project_id}/comments' do
    parameter name: 'project_id', in: :path, type: :string, description: 'project_id'

    get('list comments') do
      tags 'Comments'
      produces 'application/json'
      parameter name: :project_id, in: :path, type: :string, description: 'ID of the project for which to list comments'

      response(200, 'successful') do
        let(:project_id) { '123' }

        schema type: :object,
               properties: {
                 comments: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :integer },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' },
                       images: {
                         type: :array,
                         items: { type: :string }
                       },
                       message: { type: :string },
                       project_id: { type: :integer },
                       status: { type: :string }
                     }
                   }
                 },
                 comment_count: { type: :integer }
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


    post('create comment') do
      tags 'Comments'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :project_id, in: :path, type: :string, description: 'ID of the project to which the comment is being added'
      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          message: { type: :string },
          status: { type: :string },
          images: {
            type: :array,
            items: { type: :string }
          }
        },
        required: ['message', 'status']
      }

      response(201, 'successful') do
        let(:project_id) { '123' }

        schema type: :object,
               properties: {
                 _id: { type: :integer },
                 message: { type: :string },
                 status: { type: :string },
                 images: {
                   type: :array,
                   items: { type: :string }
                 },
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
        let(:expected_error) { 'Validation failed: [Error message]' }
        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error'],
               example: {
                 error: 'Wystąpił błąd'
               }
        run_test!
      end
    end

  end

  path '/api/projects/{project_id}/comments/{id}' do
    parameter name: 'project_id', in: :path, type: :string, description: 'project_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete comment') do
      tags 'Comments'
      produces 'application/json'
      parameter name: :project_id, in: :path, type: :string, description: 'ID of the project from which the comment is being deleted'
      parameter name: :id, in: :path, type: :string, description: 'ID of the comment to delete'

      response(204, 'no content') do
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

      response(404, 'not found') do
        let(:id) { 'non_existing_comments_id' }

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
