require 'spec_helper'

describe MiscellaneousResourcesController do
  describe 'guest access' do
    describe 'POST #copy' do
      it 'requires login' do
        post :copy
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit' do
      it 'requires login' do
        get :edit
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #show' do
      it 'requires login' do
        get :show
        expect(response).to redirect_to login_path
      end
    end

    describe 'PUT #update' do
      it 'requires login' do
        put :update
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id
      @mis = create :miscellaneous_resource
    end

    describe 'POST #copy' do
      it 'creates a new resource' do
        expect {
          post :copy, id: @mis.id
        }.to change(MiscellaneousResource, :count).by(1)
      end

      it 'redirects to the edit page for the new resource' do
        post :copy, id: @mis.id
        expect(response).to redirect_to edit_miscellaneous_resource_path(assigns(:new_mod))
      end
    end

    describe 'PUT #update' do
      it 'updates attributes of the requested guide' do
        put :update, id: @mis.id, mod: { tag_list: 'this, that, the other' }
        @mis.reload
        expect(@mis.tags.map(&:name).sort).to match_array ['that', 'the other', 'this']
      end

      it 'redirects to the :show view' do
        put :update, id: @mis.id, mod: { module_title: 'timmeh!' }
        expect(response).to redirect_to @mis
      end
    end
  end
end