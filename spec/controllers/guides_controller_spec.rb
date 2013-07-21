require 'spec_helper'

describe GuidesController do
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
    end

    describe 'POST #create' do
      it 'creates a new guide' do
        expect {
          post :create, guide: attributes_for(:guide)
        }.to change(Guide, :count).by(1)
      end

      it 'creates a default tab for the new guide' do
        post :create, guide: attributes_for(:guide)
        expect(@user.guides.first.tabs).to_not be_empty
      end

      it 'redirects to the :show view' do
        post :create, guide: attributes_for(:guide)
        expect(response).to redirect_to @user.guides.first
      end
    end

    describe 'GET #index' do
      it 'populates an array of guides' do
        guide = create :guide
        @user.add_guide guide
        get :index
        expect(assigns(:guides)).to match_array [guide]
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'assigns a new guide to @guide' do
        get :new
        expect(assigns(:guide)).to be_a_new Guide
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'individual guide' do
      before :each do
        @guide = create :guide
        @user.add_guide @guide
      end

      describe 'GET #edit' do
        it 'assigns the requested guide to @guide' do
          get :edit, id: @guide.id
          expect(assigns(:guide)).to eq @guide
        end

        it 'renders the :edit template' do
          get :edit, id: @guide.id
          expect(response).to render_template :edit
        end
      end

      describe 'GET #show' do
        it 'assigns the requested guide to @guide' do
          get :show, id: @guide.id
          expect(assigns(:guide)).to eq @guide
        end

        it 'assigns the guides tabs to @tabs' do
          get :show, id: @guide.id
          expect(assigns(:tabs)).to match_array @guide.tabs
        end

        it 'renders the :show template' do
          get :show, id: @guide.id
          expect(response).to render_template :show
        end

        it 'assigns the list of modules for the current tab to @mods' do
          tab = @guide.tabs.first
          tab.template = 1
          tab.save
          get :show, id: @guide.id
          expect(assigns(:mods)).to match_array tab.sorted_modules
        end

        it 'constructs lists of modules for the left and right columns' do
          tab = @guide.tabs.first
          get :show, id: @guide.id
          expect(assigns(:mods_left)).to match_array tab.left_modules
          expect(assigns(:mods_right)).to match_array tab.right_modules
        end

        it 'does not assign @mods in two-column layouts' do
          tab = @guide.tabs.first
          get :show, id: @guide.id
          expect(assigns(:mods)).to be_nil
        end

        it 'does not assign @mods_left or @mods_right in one-column layouts' do
          tab = @guide.tabs.first
          tab.template = 1
          tab.save
          get :show, id: @guide.id
          expect(assigns(:mods_left)).to be_nil
          expect(assigns(:mods_right)).to be_nil
        end
      end

      describe 'POST #toggle_columns' do
        it 'changes a two-column layout into a one-column layout' do
          tab = @guide.tabs.first
          post :toggle_columns, id: @guide.id
          tab.reload
          expect(tab.num_columns).to eq 1
        end

        it 'changes a one-column layout into a two-column layout' do
          tab = @guide.tabs.first
          tab.update_attribute :template, 1
          post :toggle_columns, id: @guide.id
          tab.reload
          expect(tab.num_columns).to eq 2
        end

        it 'redirects to the guide' do
          post :toggle_columns, id: @guide.id
          expect(response).to redirect_to @guide
        end
      end

      describe 'PUT #update' do
        it 'updates attributes of the requested guide' do
          put :update, id: @guide.id, guide: { tag_list: 'this, that, the other' }
          @guide.reload
          expect(@guide.tags.map(&:name).sort).to match_array ['that', 'the other', 'this']
        end

        it 'redirects to the :show view' do
          put :update, id: @guide.id, guide: { description: 'timmeh!' }
          expect(response).to redirect_to @guide
        end
      end
    end
  end
end
