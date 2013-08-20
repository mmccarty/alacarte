require 'spec_helper'

describe MastersController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #new' do
      it 'requires login' do
        get :new
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #create' do
      it 'requires login' do
        post :create
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit' do
      it 'requires login' do
        get :edit
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #update' do
      it 'requires login' do
        post :update
        expect(response).to redirect_to login_path
      end
    end

    describe 'DELETE #destroy' do
      it 'requires login' do
        delete :destroy
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'admin access' do
    before :each do
      @user = create :admin
      session[:user_id] = @user.id
      @mod = create :master
    end

    describe 'GET #index' do
      it 'assigns masters to @masters' do
        get :index
        expect(assigns(:masters)).to_not be_nil
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'assigns a new master to @master' do
        get :new
        expect(assigns(:master)).to_not be_nil
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      it 'creates a new master.' do
        expect {
          post :create, master: {value: 'my master'}
        }.to change(Master, :count).by(1)
      end

      it 'redirects to index' do
        post :create, master: {value: 'my master'}
        expect(response).to redirect_to masters_path
      end
    end

    describe 'GET #edit' do
      it 'assigns a edited master to @master' do
        get :edit, id: @mod.id
        expect(assigns(:master)).to eq @mod
      end

      it 'renders the :edit template' do
        get :edit, id: @mod.id
        expect(response).to render_template :edit
      end
    end

    describe 'POST #update' do
      it 'updates the master' do
        post :update, id: @mod.id, master: {value: 'my master'}
        @mod.reload
        expect(@mod.value).to eq 'my master'
      end
      it 'redirects to index' do
        post :update, id: @mod.id, master: {value: 'my master'}
        expect(response).to redirect_to masters_path
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes a master' do
        expect {
          delete :destroy, id: @mod.id
        }.to change(Master, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, id: @mod.id
        expect(response).to redirect_to masters_path
      end
    end
  end
end