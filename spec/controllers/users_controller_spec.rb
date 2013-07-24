require 'spec_helper'

describe UsersController do
  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id
    end

    describe 'GET #new' do
      it 'requires login'
    end

    describe 'POST #create' do
      it 'requires login'
    end
  end

  describe 'admin access' do
    before :each do
      @user = create :admin
      session[:user_id] = @user.id
    end

    describe 'GET #new' do
      it 'assigns a new user to @user' do
        get :new
        expect(assigns :user).to be_a_new User
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      it 'creates a new user' do
        expect {
          post :create, user: attributes_for(:user)
        }.to change(User, :count).by(1)
      end

      it 'redirects to the user management page' do
        post :create, user: attributes_for(:user)
        expect(response).to redirect_to users_path
      end
    end
  end
end
