require 'spec_helper'

describe DashboardsController do
  describe 'guest access' do
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

    describe 'GET #show' do
      it 'renders the show view' do
        get :show
        expect(response).to render_template :show
      end
    end
  end
end
