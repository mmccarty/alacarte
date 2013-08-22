require 'spec_helper'

describe UsersController do
  describe 'guest access' do

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

    describe 'POST #update' do
      it 'requires login' do
        post :update
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #destroy' do
      it 'requires login' do
        post :destroy
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #email_list' do
      it 'requires login' do
        get :email_list
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #pending' do
      it 'requires login' do
        get :pending
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #approve' do
      it 'requires login' do
        post :approve
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #deny' do
      it 'requires login' do
        post :deny
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'admin access' do
    before :each do
      @author = create :author
      @user = create :admin
      session[:user_id] = @user.id
    end

    describe 'GET #index' do
      it 'assigns all non-pending users to @users' do
        get :index
        expect(assigns(:users)).to_not be_nil
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'assigns a new user to @user' do
        get :new
        expect(assigns :user).to be_a_new User
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      it 'creates a new user' do
        expect {
          post :create, user: attributes_for(:user)
        }.to change(User, :count).by(1)
      end

      it 'redirects to the user management page' do
        post :create, user: attributes_for(:user)
        expect(response).to redirect_to users_path
      end

      it 'sets the password correctly' do
        attrs = attributes_for(:user)
        post :create, user: attrs
        user = User.order('id').last
        expect(user.hashed_psswrd).to eq User.encrypt(attrs[:password], user.salt)
      end
    end

    describe 'GET #edit' do
      it 'assigns the given user to @user' do
        get :edit, id: @author.id
        expect(assigns :user).to eq @author
      end

      it 'renders the :edit template' do
        get :edit, id: @author.id
        expect(response).to render_template :edit
      end
    end

    describe 'POST #update' do
      it 'assigns the given user to @user' do
        post :update, id: @author.id
        expect(assigns(:user)).to be_a_kind_of User
      end

      it 'updates the user' do
        post :update, id: @author.id, user: {name: 'foo', password: 'password', password_confirmation: 'password'}
        @author.reload
        expect(@author.name).to eq 'foo'
      end
      it 'redirects to the user index page' do
        post :update, id: @author.id, user: {name: 'foo', password: 'password', password_confirmation: 'password'}
        expect(response).to redirect_to users_path
      end
      it 'renders the edit template on save failure' do
        post :update, id: @author.id, user: {name: nil}
        expect(response).to render_template :edit
      end
    end

    describe 'POST #destroy' do
      it 'destroys the user' do
        expect {
          post :destroy, id: @author.id
        }.to change(User, :count).by(-1)
      end

      it 'redirects to the user index page' do
        post :destroy, id: @author.id
        expect(response).to redirect_to users_path
      end
    end

    describe 'GET #email_list' do
      it 'populates a list of emails as @emails' do
        get :email_list
        expect(assigns(:emails)).to be_a_kind_of String
      end

      it 'renders the email_list template' do
        get :email_list
        expect(response).to render_template :email_list
      end
    end

    context 'dealing with user account requests' do
      before :each do
        @pending = create :author
        @pending.role = 'pending'
        @pending.save
      end

      describe 'GET #pending' do
        it 'populates a list of pending users as @users' do
          get :pending
          expect(assigns(:users).empty?).to be_false
        end

        it 'renders the pending template' do
          get :pending
          expect(response).to render_template :pending
        end
      end

      describe 'POST #approve' do
        it 'assigns the given user to @user' do
          post :approve, id: @pending.id
          expect(assigns(:user)).to be_a_kind_of User
        end

        it 'sets the user role to "author"' do
          post :approve, id: @pending.id
          @pending.reload
          expect(@pending.role).to eq 'author'
        end

        it 'redirects to :pending' do
          post :approve, id: @pending.id
          expect(response).to redirect_to action: :pending
        end
      end

      describe 'POST #deny' do
        it 'assigns the given user to @user' do
          post :deny, id: @pending.id
          expect(assigns(:user)).to be_a_kind_of User
        end

        it 'destroys the given user' do
          post :deny, id: @pending.id
          expect {
            @pending.reload
          }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'redirects to :pending' do
          post :deny, id: @pending.id
          expect(response).to redirect_to action: :pending
        end
      end
    end
  end
end
