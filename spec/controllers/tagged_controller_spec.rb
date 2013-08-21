require 'spec_helper'

describe TaggedController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

  end
  describe 'admin access' do
    before :each do
      @user = create :admin
      session[:user_id] = @user.id

      Local.create
    end
    describe 'GET #index' do
      it 'assigns mods' do
        get :index
        expect(assigns(:mods)).to_not be_nil
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template :index
      end
    end
  end
end