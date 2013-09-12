require 'spec_helper'

describe BookController do
  describe 'guest access' do
    describe 'POST #copy' do
      it 'requires login' do
        post :copy
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #retrieve_results' do
      it 'requires login' do
        get :retrieve_results
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit_book' do
      it 'requires login' do
        get :edit_book
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #save_book' do
      it 'requires login' do
        get :save_book
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #update_book' do
      it 'requires login' do
        post :update_book
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'admin access' do
    before :each do
      @user = create :admin
      session[:user_id] = @user.id

      @book_resource = create :book_resource
    end

    describe 'POST #copy' do
      it 'creates a new book resource' do
        expect {
          post :copy, id: @book_resource.id
        }.to change(BookResource, :count).by(1)
      end

      it 'redirects to :edit_book' do
        post :copy, id: @book_resource.id
        expect(response).to redirect_to action: :edit_book, id: assigns(:new_mod)
      end

      it 'assigns the new book resource to @new_mod' do
        post :copy, id: @book_resource.id
        expect(assigns(:new_mod)).to_not be_nil
      end
    end

    describe 'GET #retrieve_results'

    describe 'GET #edit_book' do
      it 'assigns the edited book to @mod' do
        get :edit_book, id: @book_resource.id
        expect(assigns(:mod)).to_not be_nil
      end

      it 'renders the :edit_book template' do
        get :edit_book, id: @book_resource.id
        expect(response).to render_template :edit_book
      end
    end

    describe 'GET #save_book' do
      it 'assigns the given book to @mod' do
        get :save_book, id: @book_resource.id
        expect(assigns(:mod)).to_not be_nil
      end

      it 'creates a new book' do
        expect {
          get :save_book, id: @book_resource.id
        }.to change(Book, :count).by(1)
      end
    end

    describe 'POST #update_book' do
      it 'assigns the given book resource to @mod' do
        post :update_book, id: @book_resource.id, mod: {}
        expect(assigns(:mod)).to_not be_nil
      end

      it 'updates the book resource' do
        post :update_book, id: @book_resource.id, mod: {module_title: 'foo'}
        @book_resource.reload
        expect(@book_resource.module_title).to eq 'foo'
      end

      it 'redirects to the preview' do
        post :update_book, id: @book_resource.id, mod: {module_title: 'foo'}
        expect(response).to redirect_to controller: :module,
                                        action: :preview,
                                        id: @book_resource.id,
                                        type: @book_resource.class
      end

      it 'renders the edit_book template on save failure' do
        post :update_book, id: @book_resource.id, mod: {module_title: nil}
        expect(response).to render_template :edit_book
      end
    end
  end
end
