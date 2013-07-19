require 'spec_helper'

describe DashboardsController do
  describe 'guest access' do
    describe 'GET #edit_profile' do
      it 'requires login' do
        get :edit_profile
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #my_account' do
      it 'requires login' do
        get :my_account
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #show' do
      it 'requires login' do
        get :show
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      user = create :author
      session[:user_id] = user.id
    end

    describe 'GET #edit_profile' do
      it 'renders the :edit_profile view' do
        get :edit_profile
        expect(response).to render_template :edit_profile
      end
    end

    describe 'GET #my_account' do
      it 'renders the :my_account view' do
        get :my_account
        expect(response).to render_template :my_account
      end
    end

    describe 'GET #show' do
      it 'renders the :show view' do
        get :show
        expect(response).to render_template :show
      end
    end
  end
end
