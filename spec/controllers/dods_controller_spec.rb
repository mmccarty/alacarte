require 'spec_helper'

describe DodsController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'PUT #new' do
      it 'requires login' do
        put :new
        expect(response).to redirect_to login_path
      end
    end

    describe 'PUT #create' do
      it 'requires login' do
        put :create
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

      @dod = create :dod
    end

    describe 'GET #index' do
      it 'assigns all the dods to @dods' do
        get :index
        expect(assigns(@dods)).to_not be_nil
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'PUT #new' do
      it 'assigns the requested dod to @dod' do
        put :new
        expect(assigns(:dod)).to_not be_nil
      end

      it 'renders the :new template' do
        put :new
        expect(response).to render_template :new
      end

    end

    describe 'GET #edit' do
      it 'assigns the requested dod to @dod' do
        get :edit, id: @dod.id
        expect(assigns(:dod)).to_not be_nil
      end

      it 'renders the :edit template' do
        get :edit, id: @dod.id
        expect(response).to render_template :edit
      end
    end

    describe 'PUT #create' do
      it 'creates a new dod' do
        expect {
          put :create, dod: {title: 'test dod',
                             url: 'foo.com',
                             provider: 'Nub Games',
                             descr: 'test dod'}
        }.to change(Dod, :count).by(1)
      end

      it 'redirects to dods index' do
        put :create, dod: {title: 'test dod',
                           url: 'foo.com',
                           provider: 'Nub Games',
                           descr: 'test dod'}
        expect(response).to redirect_to dods_path
      end
    end

    describe 'POST #update' do
      it 'updates the dod' do
        post :update, id: @dod.id, dod: {title: 'mod test dod'}
        @dod.reload
        expect(@dod.title).to eq 'mod test dod'
      end
      it 'redirects to the dods index' do
        post :update, id: @dod.id, dod: {title: 'mod test dod'}
        expect(response).to redirect_to dods_path
      end
    end

    describe 'DELETE #destroy' do
      it 'decreases the dod count by -1' do
        expect {
          delete :destroy, id: @dod.id
        }.to change(Dod, :count).by(-1)
      end
      it 'redirects to the dods index' do
        delete :destroy, id: @dod.id
        expect(response).to redirect_to dods_path
      end
    end
  end
end