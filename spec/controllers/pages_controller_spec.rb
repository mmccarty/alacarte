require 'spec_helper'

describe PagesController do
  describe 'guest access' do
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

      @subject = create :subject

      Local.create
    end

    describe 'POST #create' do
      it 'creates a new page' do
        expect {
          post :create, page: attributes_for(:page), subjects: [@subject.id]
        }.to change(Page, :count).by(1)
      end

      it 'creates a default tab for the new page' do
        post :create, page: attributes_for(:page), subjects: [@subject.id]
        expect(@user.pages.first.tabs).to_not be_empty
      end

      it 'sets the list of subjects for the new page' do
        post :create, page: attributes_for(:page), subjects: [@subject.id]
        expect(@user.pages.first.subjects).to match_array [@subject]
      end

      it 'redirects to the :show view' do
        post :create, page: attributes_for(:page), subjects: [@subject.id]
        expect(response).to redirect_to @user.pages.first
      end
    end

    describe 'GET #index' do
      it 'populates an array of pages' do
        page = create :page
        @user.add_page page
        get :index
        expect(assigns(:pages)).to match_array [page]
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'assigns a new page to @page' do
        get :new
        expect(assigns(:page)).to be_a_new Page
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'individual page' do
      before :each do
        @page = create :page
        @user.add_page @page
      end

      describe 'GET #edit' do
        it 'assigns the requested page to @page' do
          get :edit, id: @page.id
          expect(assigns(:page)).to eq @page
        end

        it 'renders the :edit template' do
          get :edit, id: @page.id
          expect(response).to render_template :edit
        end
      end

      describe 'GET #show' do
        it 'assigns the requested page to @page' do
          get :show, id: @page.id
          expect(assigns(:page)).to eq @page
        end

        it 'assigns the pages tabs to @tabs' do
          get :show, id: @page.id
          expect(assigns(:tabs)).to match_array @page.tabs
        end

        it 'renders the :show template' do
          get :show, id: @page.id
          expect(response).to render_template :show
        end
      end

      describe 'PUT #update' do
        it 'redirects to the :show view' do
          put :update, id: @page.id, page: { course_name: 'timmeh!' }
          expect(response).to redirect_to @page
        end
      end
    end
  end
end
