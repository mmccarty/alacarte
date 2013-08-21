require 'spec_helper'

describe InstResourcesController do
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
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id
      @mod = create :inst_resource
    end

    describe 'GET #show' do
      it 'sets the requested resource to @mod' do
        get :show, id: @mod.id
        expect(assigns(:mod)).to eq @mod
      end

      it 'renders the show template' do
        get :show, id: @mod.id
        expect(response).to render_template :show
      end
    end

    describe 'GET #edit' do
      it 'sets the requested resource to @mod' do
        get :edit, id: @mod.id
        expect(assigns(:mod)).to eq @mod
      end

      it 'renders the edit template' do
        get :edit, id: @mod.id
        expect(response).to render_template :edit
      end
    end

    describe 'POST #update after new' do
      before :each do
        @attrs = attributes_for :inst_resource
        @attrs[:instructor_name] = 'foo'
        @attrs[:type] = 'InstResource'

        @module = InstResource.new
        @module.update_attributes @attrs
        @module.slug = @attrs[:module_title]
        @module.save
      end
      it 'updates the resource' do
        post :update, id: @module.id, inst_resource: @attrs
        expect(assigns(:mod).instructor_name).to eq @attrs[:instructor_name]
      end
    end

    describe 'POST #update' do
      it 'sets the requested resource to @mod' do
        post :update, id: @mod.id, inst_resource: {email: 'foo@bar.com'}
        expect(assigns(:mod)).to eq @mod
      end

      it 'renders the edit template if save fails' do
        post :update, id: @mod.id, inst_resource: {email: 'invalid email'}
        expect(response).to render_template :edit
      end

      it 'saves the resource' do
        post :update, id: @mod.id, inst_resource: {email: 'foo@bar.com'}
        @mod.reload
        expect(@mod.email).to eq 'foo@bar.com'
      end
    end

    describe 'POST #copy' do
      it 'redirects to edit' do
        post :copy, id: @mod.id
        expect(response).to redirect_to edit_inst_resource_path(assigns(:new_mod))
      end

      it 'creates a new resource' do
        expect {
          post :copy, id: @mod.id
        }.to change(InstResource, :count).by(1)

      end
    end
  end
end