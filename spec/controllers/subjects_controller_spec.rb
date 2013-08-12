require 'spec_helper'

describe SubjectsController do
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
      @mod = create :subject
    end

    describe 'GET #index' do
      it 'assigns subjects to @subjects' do
        get :index
        expect(assigns(:subjects)).to_not be_nil
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'assigns a new subject to @subject' do
        get :new
        expect(assigns(:subject)).to_not be_nil
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      it 'creates a new subject.' do
        expect {
          post :create, subject: {subject_name: 'my subject', subject_code: '1'}
        }.to change(Subject, :count).by(1)
      end

      it 'redirects to index' do
        post :create, subject: {subject_name: 'my subject', subject_code: '1'}
        expect(response).to redirect_to subjects_path
      end
    end

    describe 'GET #edit' do
      it 'assigns a edited subject to @subject' do
        get :edit, id: @mod.id
        expect(assigns(:subject)).to eq @mod
      end

      it 'renders the :edit template' do
        get :edit, id: @mod.id
        expect(response).to render_template :edit
      end
    end

    describe 'POST #update' do
      it 'updates the subject' do
        post :update, id: @mod.id, subject: {subject_name: 'my subject', subject_code: '2'}
        @mod.reload
        expect(@mod.subject_code).to eq '2'
      end
      it 'redirects to index' do
        post :update, id: @mod.id, subject: {subject_name: 'my subject', subject_code: '2'}
        expect(response).to redirect_to subjects_path
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes a subject' do
        expect {
          delete :destroy, id: @mod.id
        }.to change(Subject, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, id: @mod.id
        expect(response).to redirect_to subjects_path
      end
    end
  end
end