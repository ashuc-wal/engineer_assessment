require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user) }

  context "POST #sign_in" do
    example "user should be sign in if email/password if correct" do
      post :create, params: { email: user.email, password: '123456' }, format: :json

      expect(response).to have_http_status(200)

      resp = JSON.parse(response.body)
      expect(resp["token"]).not_to be_nil
      expect(resp["refresh_token"]).not_to be_nil
    end

    example "user should not be sign in if email/password are incorrect" do
      post :create, params: { email: user.email, password: '1234567' }, format: :json

      expect(response).to have_http_status(422)
    end
  end

  context "GET #refresh_token" do
    before do
      post :create, params: { email: user.email, password: '123456' }, format: :json
      resp = JSON.parse(response.body)
      @access_token = resp["token"]
      @refresh_token = resp["refresh_token"]
    end

    example "user should be able to refresh access token with refresh token" do
      @request.headers['X-REFRESH-TOKEN'] = @refresh_token
      get :refresh_token, params: {}, format: :json

      resp = JSON.parse(response.body)
      expect(resp["token"]).not_to be_nil
    end

    example "user should get if refresh token got tampered" do
      @request.headers['X-REFRESH-TOKEN'] = '1234.1234.1234'
      get :refresh_token, params: {}, format: :json
      expect(response).to have_http_status(400)
    end
  end
end
