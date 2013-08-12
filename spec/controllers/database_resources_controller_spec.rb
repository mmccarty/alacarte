require 'spec_helper'

describe DatabaseResourcesController do
  describe 'guest access' do
    describe 'GET #show' do
      it 'requires login' do
        get :show
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

    describe 'POST #copy' do
      it 'requires login' do
        post :copy
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_databases' do
      it 'requires login' do
        post :add_databases
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id
      @mod = create :database_resource
      @local = create :local
    end

    describe 'GET #show' do
      it 'assigns the resource to @mod' do
        get :show, id: @mod.id
        expect(assigns(:mod)).to eq @mod
      end

      it 'renders the :show template' do
        get :show, id: @mod.id
        expect(response).to render_template :show
      end
    end

    describe 'GET #edit' do
      it 'assigns a edited resource to @mod' do
        get :edit, id: @mod.id
        expect(assigns(:mod)).to eq @mod
      end

      it 'renders the :edit template' do
        get :edit, id: @mod.id
        expect(response).to render_template :edit
      end
    end

    describe 'POST #update' do
      it 'assigns the resource to @mod' do
        post :update, id: @mod.id
        expect(assigns(:mod)).to eq @mod
      end

      it 'redirects to show on success' do
        post :update, id: @mod.id, mod: {module_title: 'my title'}
        expect(response).to redirect_to @mod
      end

      it 'renders :edit template on failure' do
        post :update, id: @mod.id, mod: {module_title: nil}
        expect(response).to render_template :edit
      end
    end

    describe 'POST #copy' do
      it 'creates a new resource' do
        expect {
          post :copy, id: @mod.id
        }.to change(DatabaseResource, :count).by(1)
      end

      it 'redirects to edit' do
        post :copy, id: @mod.id
        expect(response).to redirect_to edit_database_resource_path(assigns(:new_mod))
      end
    end

    describe 'POST #add_databases' do
      before :each do
        @dod = create :dod
      end
      it 'assigns the resource to @mod' do
        post :add_databases, id: @mod.id
        expect(assigns(:mod)).to eq @mod
      end

      it 'adds the databases to the resource' do
        session[:selected] = [@dod.id]
        post :add_databases, id: @mod.id
        expect(@mod.dods.length).to eq 1
      end

      it 'redirects to :edit_databases' do
        session[:selected] = [@dod.id]
        post :add_databases, id: @mod.id
        expect(response).to redirect_to action: :edit_databases, id: @mod.id
      end
    end
  end
end