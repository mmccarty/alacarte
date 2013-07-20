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
