require 'spec_helper'

describe CommentResourcesController do
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

    describe 'PUT #create' do
      it 'requires login' do
        put :create
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id

      @comment = create :comment_resource
      @com = create :comment, comment_resource: @comment

    end

    describe 'GET #show' do
      it 'assigns the requested comment to @mod' do
        get :show, id: @comment.id
        expect(assigns(:mod)).to eq @comment
      end

      it 'renders the :show template' do
        get :show, id: @comment.id
        expect(response).to render_template :show
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested comment to @mod' do
        get :edit, id: @comment.id
        expect(assigns(:mod)).to eq @comment
      end

      it 'renders the :edit template' do
        get :edit, id: @comment.id
        expect(response).to render_template :edit
      end
    end

    describe 'POST #update' do
      it 'assigns the requested comment to @mod' do
        post :update, id: @comment.id
        expect(assigns(:mod)).to eq @comment
      end

      it 'updates attributes of the requested comment' do
        put :update, id: @comment.id, mod: { topic: 'timmeh!' }
        @comment.reload
        expect(@comment.topic).to eq 'timmeh!'
      end

      it 'redirects to the :show view' do
        put :update, id: @comment.id, mod: { topic: 'timmeh!' }
        expect(response).to redirect_to @comment
      end
    end

    describe 'PUT #create' do
      before :each do
        request.env['HTTP_REFERER'] = '/back'
      end

      it 'assigns the requested comment resource to @mod' do
        put :create, resource_id: @comment.id, comment: { author_name: 'timmeh!' }
        expect(assigns(:mod)).to eq @comment
      end

      it 'redirects back' do
        put :create, resource_id: @comment.id, comment: { author_name: 'timmeh!' }
        expect(response).to redirect_to '/back'
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys a comment' do
        request.env['HTTP_REFERER'] = '/back'
        expect {
          delete :destroy, id: @com.id
        }.to change(Comment, :count).by(-1)
      end
    end

    describe 'POST #purge_comments' do
      it 'destroys a comment' do
        request.env['HTTP_REFERER'] = '/back'
        expect {
          post :purge_comments, resource_id: @comment.id
        }.to change(Comment, :count).by(-1)
      end
    end
  end
end