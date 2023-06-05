module Api
class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show update destroy ]

  def index
    @project = Project.find(params[:project_id])
    @comments = @project.comments
    @comment_count = @comments.count
    render json: { comments: @comments, comment_count: @comment_count }
  end

=begin
  def show
    render json: @comment
  end
=end

  def create
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
    @comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end
end
end
