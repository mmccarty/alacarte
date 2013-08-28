require 'spec_helper'

describe UrlResourcesController do
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
      @mod = create :url_resource

      Local.create
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

    describe 'POST #update' do
      it 'sets the requested resource to @mod' do
        post :update, id: @mod.id, url_resource: {module_title: 'foo', label: 'bar'}
        expect(assigns(:mod)).to eq @mod
      end

      it 'renders the edit template if save fails' do
        post :update, id: @mod.id, url_resource: {module_title: nil}
        expect(response).to render_template :edit, id: @mod.id
      end

      it 'saves the resource' do
        post :update, id: @mod.id, url_resource: {module_title: 'foo', label: 'bar'}
        @mod.reload
        expect(@mod.module_title).to eq 'foo'
      end
    end

    describe 'POST #copy' do
      it 'redirects to edit' do
        post :copy, id: @mod.id
        expect(response).to redirect_to edit_url_resource_path(assigns(:new_mod))
      end

      it 'creates a new resource' do
        expect {
          post :copy, id: @mod.id
        }.to change(UrlResource, :count).by(1)

      end
    end

    describe 'POST #sort_links' do
      it 'rearranges links to be in the specified order' do
        3.times { @mod.links << build(:link) }
        links = @mod.links.clone
        post :reorder_links, link_ids: [links[2].id, links[0].id, links[1].id]
        @mod.reload
        expect(@mod.links).to eq [links[2], links[0], links[1]]
      end

      it 'renders nothing' do
        3.times { @mod.links << build(:link) }
        links = @mod.links.clone
        post :reorder_links, link_ids: [links[2].id, links[0].id, links[1].id]
        expect(response.body).to be_blank
      end
    end
  end
end