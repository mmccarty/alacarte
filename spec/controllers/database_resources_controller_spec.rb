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
        post :update, id: @mod.id, database_resource: {module_title: 'my title'}
        expect(response).to redirect_to @mod
      end

      it 'renders :edit template on failure' do
        post :update, id: @mod.id, database_resource: {module_title: nil}
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

    context 'adding database' do
      before :each do
        @dod = create :dod
      end

      describe 'POST #add_databases' do

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
          expect(response).to redirect_to polymorphic_path @mod, action: :edit
        end
      end

      describe 'GET #add_databases' do
        it 'empties selected items' do
          get :add_databases, id: @mod.id
          expect(session[:selected]).to eq []
        end

        it 'assigns all the Dods to @dods' do
          get :add_databases, id: @mod.id
          expect(assigns(:dods)).to_not be_nil
        end
        it 'renders :add_databases template' do
          get :add_databases, id: @mod.id
          expect(response).to render_template :add_databases
        end
      end
    end
  end
end