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

        it 'assigns the list of modules for the current tab to @mods' do
          tab = @page.tabs.first
          tab.template = 1
          tab.save
          get :show, id: @page.id
          expect(assigns(:mods)).to match_array tab.sorted_modules
        end

        it 'constructs lists of modules for the left and right columns' do
          tab = @page.tabs.first
          get :show, id: @page.id
          expect(assigns(:mods_left)).to match_array tab.left_modules
          expect(assigns(:mods_right)).to match_array tab.right_modules
        end

        it 'does not assign @mods in two-column layouts' do
          tab = @page.tabs.first
          get :show, id: @page.id
          expect(assigns(:mods)).to be_nil
        end

        it 'does not assign @mods_left or @mods_right in one-column layouts' do
          tab = @page.tabs.first
          tab.template = 1
          tab.save
          get :show, id: @page.id
          expect(assigns(:mods_left)).to be_nil
          expect(assigns(:mods_right)).to be_nil
        end
      end

      describe 'POST #toggle_columns' do
        it 'changes a two-column layout into a one-column layout' do
          tab = @page.tabs.first
          post :toggle_columns, id: @page.id
          tab.reload
          expect(tab.num_columns).to eq 1
        end

        it 'changes a one-column layout into a two-column layout' do
          tab = @page.tabs.first
          tab.update_attribute :template, 1
          post :toggle_columns, id: @page.id
          tab.reload
          expect(tab.num_columns).to eq 2
        end

        it 'redirects to the page' do
          post :toggle_columns, id: @page.id
          expect(response).to redirect_to @page
        end
      end

      describe 'PUT #update' do
        it 'updates attributes of the requested page' do
          put :update, id: @page.id, page: { tag_list: 'this, that, the other' }
          @page.reload
          expect(@page.tags.map(&:name).sort).to match_array ['that', 'the other', 'this']
        end

        it 'redirects to the :show view' do
          put :update, id: @page.id, page: { course_name: 'timmeh!' }
          expect(response).to redirect_to @page
        end
      end
    end
  end
end
