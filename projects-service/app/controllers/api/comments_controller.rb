module Api
class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show update destroy ]

  # GET /comments
  def index
    @comments = Comment.all
    @comment_count = Comment.count
    render json: {comments: @comments, comment_count: @comment_count}
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST /comments
  def create
    @project = Project.find(params[:project_id])

    @comment = @project.comments.build(
      message: params[:message],
      status: params[:status],
    )

    if @comment.save
      render json: @comment, status: :created, location: api_project_comment_url(@project, @comment)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(
      message: params[:message],
      status: params[:status]
    )
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
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
