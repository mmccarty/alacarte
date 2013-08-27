require 'spec_helper'

describe LinksController do
  describe 'guest access' do
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

      @url_resource = create :url_resource
      @link = create :link
      @url_resource.links << @link
    end

    describe 'PUT #new' do
      it 'assigns the requested dod to @dod' do
        put :new, url_resource_id: @url_resource.id
        expect(assigns(:link)).to_not be_nil
      end

      it 'renders the :new template' do
        put :new, url_resource_id: @url_resource.id
        expect(response).to render_template :new
      end

    end

    describe 'GET #edit' do
      it 'assigns the requested dod to @dod' do
        get :edit, url_resource_id: @url_resource.id, id: @link.id
        expect(assigns(:link)).to_not be_nil
      end

      it 'renders the :edit template' do
        get :edit, url_resource_id: @url_resource.id, id: @link.id
        expect(response).to render_template :edit
      end
    end

    describe 'PUT #create' do
      it 'creates a new dod' do
        expect {
          put :create, url_resource_id: @url_resource.id, link: {description: 'test link',
                                                                 url: 'http://foo.com'}
        }.to change(Link, :count).by(1)
      end

      it 'redirects to link path' do
        put :create, url_resource_id: @url_resource.id, link: {description: 'test link',
                                                               url: 'http://foo.com'}
        expect(response).to redirect_to edit_url_resource_path @link.url_resource
      end
    end

    describe 'POST #update' do
      it 'updates the link' do
        post :update, url_resource_id: @url_resource.id, id: @link.id, link: {description: 'mod test link'}
        @link.reload
        expect(@link.description).to eq 'mod test link'
      end
      it 'redirects to the link path' do
        post :update, url_resource_id: @url_resource.id, id: @link.id, link: {description: 'mod test dod'}
        expect(response).to redirect_to edit_url_resource_path @link.url_resource
      end
    end

    describe 'DELETE #destroy' do
      it 'decreases the dod count by -1' do
        expect {
          delete :destroy, url_resource_id: @url_resource.id, id: @link.id
        }.to change(Link, :count).by(-1)
      end
      it 'redirects to the url_resource' do
        delete :destroy, url_resource_id: @url_resource.id, id: @link.id
        expect(response).to redirect_to edit_url_resource_path @link.url_resource
      end
    end
  end
end