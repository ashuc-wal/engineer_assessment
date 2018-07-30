require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  render_views

  let!(:valid_attrs) do
    { title: 'first title', url: "http://localhost:4000" }
  end

  let!(:invalid_attrs) do
    { title: '', url: "http://localhost:4000" }
  end

  context "GET #index" do
    let!(:posts) { create_list(:post, 2) }

    it "returns a success response" do
      first_post = posts.first
      last_post = posts.last

      get :index, params: {}, format: :json

      expect(response).to have_http_status(:ok)
      posts = JSON.parse(response.body)
      expect(posts.first.fetch_values("id", "title", "url")).to eq([first_post.id,
                    first_post.title, first_post.url])
      expect(posts.last.fetch_values("id", "title", "url")).to eq([last_post.id,
                    last_post.title, last_post.url])
    end
  end

  context "GET #show" do
    let!(:post) { create(:post) }

    it "returns a success response" do
      get :show, params: {id: post.to_param}, format: :json

      expect(response).to have_http_status(:ok)
      post1 = JSON.parse(response.body)
      expect(post1.fetch_values("id", "title", "url")).to eql([post.id, post.title, post.url])
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user) }
    before do
      @request.headers['X-ACCESS-TOKEN'] = user.generate_token
    end

    context "with valid params" do
      it "creates a new Post" do
        expect {
    post :create,
    params: {post: valid_attrs }, format: :json
        }.to change(Post, :count).by(1)

        expect(response).to have_http_status(:created)
  _post = JSON.parse(response.body)
  post = Post.last
        expect(_post.fetch_values("id", "title", "url")).to eql([post.id, post.title, post.url])
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new post" do
        post :create, params: {post: invalid_attrs}, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    let!(:user) { create(:user) }

    before do
      @request.headers['X-ACCESS-TOKEN'] = user.generate_token
    end

    context "with valid params" do
      let(:new_attributes) do
  { title: 'second title', url: 'http://localhost:3000/second-title' }
      end

      it "updates the requested post" do
        post = create(:post, user: user)
        put :update, params: {id: post.to_param, post: new_attributes}, format: :json
  post.reload

  expect(post.title).to eq('second title')
  expect(post.url).to eq('http://localhost:3000/second-title')
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the post" do
        _post = create(:post)

        put :update, params: {id: _post.to_param, post: invalid_attrs}, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:user) }

    before do
      @request.headers['X-ACCESS-TOKEN'] = user.generate_token
    end

    it "destroys the requested post" do
      post = create(:post, user: user)
      expect {
  delete :destroy, params: {id: post.to_param}, format: :json
      }.to change(Post, :count).by(-1)
    end

    it "should not be able to delete another user post" do
      post = create(:post)
      delete :destroy, params: {id: post.to_param}, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
