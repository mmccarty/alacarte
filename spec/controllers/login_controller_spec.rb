require 'spec_helper'

describe LoginController do
  describe 'GET #login' do
    it 'responds successfully with an HTTP 200 status code' do
      get :login
      expect(response).to be_success
      expect(response.status).to eq 200
    end
  end

  describe 'GET #logout' do
    it 'clears the user identity from the session' do
      get :logout
      expect(session[:user_id]).to be_nil
    end

    it 'redirects back to the login page' do
      get :logout
      response.should redirect_to login_path
    end
  end

  describe 'GET #forgot_password' do
    it 'responds successfully with an HTTP 200 status code' do
      get :forgot_password
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #forgot_password' do
    before :each do
      @user = create :author, email: 'test@nubgames.com'
    end

    it 'redirect to login page' do
      post :forgot_password, user: {email: @user.email}
      expect(response).to redirect_to action: :login
    end

    it 'sets a new password' do
      password = @user.password
      post :forgot_password, user: {email: @user.email}
      @user = User.find_by_email @user.email
      expect(password).to_not eq @user.password
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
