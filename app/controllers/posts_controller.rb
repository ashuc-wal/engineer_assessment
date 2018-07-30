class PostsController < ApplicationController
  load_and_authorize_resource only: %i[index show update destroy]
  before_action :authenticate!, except: %i[index show]

  # GET /posts
  def index
    @posts = Post.all
  end

  # GET posts/:id
  def show
    @post = Post.find(params[:id])
  end

  # POST /posts
  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      render :show, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PUT /posts/:id
  def update
    if @post.update(post_params)
      render :show, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy
  end

  private

  def post_params
    params.require(:post).permit(:title, :url)
  end
end
