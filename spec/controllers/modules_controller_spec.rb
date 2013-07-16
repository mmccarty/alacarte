require 'spec_helper'

describe ModulesController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #new' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      user = create :author
      session[:user_id] = user.id

      Local.create
    end

    describe 'GET #index' do
      it 'renders the index view' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'renders the new module form' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      it 'renders the new module form when no module type is specified' do
        post :create, mod: { type: '' }
        expect(response).to render_template :new
      end
    end
  end
end
