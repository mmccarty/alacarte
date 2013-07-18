require 'spec_helper'

describe ModulesController do
  describe 'for guests' do
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

    describe 'GET #manage' do
      it 'requires login' do
        get :manage
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_guide' do
      it 'requires login' do
        post :add_guide
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_guide' do
      it 'requires login' do
        post :add_to_guide
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_page' do
      it 'requires login' do
        post :add_page
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_page' do
      it 'requires login' do
        post :add_to_page
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_tutorial' do
      it 'requires login' do
        post :add_tutorial
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_tutorial' do
      it 'requires login' do
        post :add_to_tutorial
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'for authors' do
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
      it 'requires the user to specify the module type' do
        post :create, mod: { type: '' }
        expect(response).to render_template :new
      end
    end

    describe 'GET #manage' do
      it 'renders the module management page'
    end

    describe 'POST #add_guide' do
      it 'adds the guide to the session'
      it 'renders nothing'
    end

    describe 'POST #add_to_guide' do
      it 'adds guides from the session to the module'
      it 'redirects to the module management page'
    end

    describe 'POST #add_page' do
      it 'adds the page to the session'
      it 'renders nothing'
    end

    describe 'POST #add_to_page' do
      it 'adds pages from the session to the module'
      it 'redirects to the module management page'
    end

    describe 'POST #add_tutorial' do
      it 'adds the tutorial to the session'
      it 'renders nothing'
    end

    describe 'POST #add_to_tutorial' do
      it 'adds tutorials from the session to the module'
      it 'redirects to the module management page'
    end
  end
end
