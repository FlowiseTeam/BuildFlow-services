module Api
class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show update destroy ]

  def index
    begin
      @project = Project.find(params[:project_id])
      @comments = @project.comments
      @comment_count = @comments.count
      if @comment_count.zero?
        render json: { message: 'Nie znaleziono' }
      else
        render json: { comments: @comments, comment_count: @comment_count }
      end
    rescue StandardError => e
      render(json: { error: 'Wystąpił błąd' }, status: :internal_server_error)
    end
  end

=begin
  def show
    render json: @comment
  end
=end

  def create
    begin
      @project = Project.find(params[:project_id])

      @comment = @project.comments.build(
        message: params[:message],
        status: params[:status],
        images: params[:images],
        )

      if @comment.save
        render json: @comment, status: :created, location: api_project_comment_url(@project, @comment)
      else
        render json: @comment.errors.full_messages.to_sentence, status: :unprocessable_entity
      end
    rescue StandardError => e
      render(json: { error: 'Wystąpił błąd' }, status: :internal_server_error)
    end
  end

=begin
  def update
    if @comment.update(
      message: params[:message],
      status: params[:status],
      images: params[:images]
    )
      render json: @comment
    else
      render json: @comment.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end
=end

  def destroy
    begin
      @comment = Comment.find(params[:id])
      @comment.destroy
      head :no_content
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      begin
        @comment = Comment.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
      rescue StandardError => e
        render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
      end
    end
end
end
