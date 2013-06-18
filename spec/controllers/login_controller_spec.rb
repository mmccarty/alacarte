require 'spec_helper'

describe LoginController do
  describe 'GET #login' do
    it 'responds successfully with an HTTP 200 status code' do
      get :login
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #logout' do
    it 'clears the user identity from the session' do
      get :logout
      expect(session[:user_id]).to be_nil
    end

    it 'redirects back to the home page' do
      get :logout
      response.should redirect_to '/'
    end
  end

  describe 'GET #forgot_password' do
    it 'responds successfully with an HTTP 200 status code' do
      get :forgot_password
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #signup' do
    it 'responds successfully with an HTTP 200 status code' do
      get :signup
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
end
