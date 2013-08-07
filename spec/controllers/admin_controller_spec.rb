require 'spec_helper'

describe AdminController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'admin access' do
    before :each do
      @user = create :admin
      session[:user_id] = @user.id
    end

    describe 'GET #index' do
      it 'assigns user_count to @user_count' do
        get :index
        expect(assigns(:user_count)).to_not be_nil
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'POST #auto_archive' do
      before :each do
        request.env['HTTP_REFERER'] = '/foo'
      end

      describe 'affect on pages' do
        before :each do
          @page = create :page, published: true, updated_at: Time.now.months_ago(7)
        end
        it 'archives old, published pages' do
          post :auto_archive
          @page.reload
          expect(@page.archived?).to be_true
        end

        it 'does not archive new pages' do
          @page.updated_at = Time.now
          @page.save
          post :auto_archive
          expect(@page.archived?).to be_false
        end

        it 'does not archive unpublished pages' do
          @page.published = false
          @page.save
          post :auto_archive
          @page.reload
          expect(@page.archived?).to be_false
        end
      end

      describe 'affect on guides' do
        before :each do
          @guide = create :guide, published: true, updated_at: Time.now.months_ago(13)
        end

        it 'unpublishes old, published guides' do
          post :auto_archive
          @guide.reload
          expect(@guide.published?).to be_false
        end

        it 'does not unpublish new, published guides' do
          @guide.updated_at = Time.now
          @guide.save
          post :auto_archive
          @guide.reload
          expect(@guide.published?).to be_true
        end
      end
    end

    describe 'GET #guides' do
      before :each do
        @user.guides << create(:guide)
      end

      it 'sets requested user to @user' do
        get :guides, id: @user.id
        expect(assigns(:user)).to eq @user
      end

      it 'sets @guides to the requested user\'s guides' do
        get :guides, id: @user.id
        expect(assigns(:guides)).to eq @user.guides
      end

      it 'sets guide count to @count' do
        get :guides, id: @user.id
        expect(assigns(:count)).to eq @user.guides.size
      end

      it 'renders the :guide template' do
        get :guides, id: @user.id
        expect(response).to render_template :guide
      end
    end

    describe 'POST #destroy_guide' do
      before :each do
        @author = create :author
        session[:author] = @author.id
        @guide = create(:guide)
        @author.guides << @guide
        request.env['HTTP_REFERER'] = '/foo'
      end

      it 'deletes the guide when there is one owner' do
        post :destroy_guide, id: @guide.id
        expect {
          @guide.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'just deletes the association when there is more than one owner' do
        @user.guides << @guide
        post :destroy_guide, id: @guide.id
        expect {
          @guide.reload
        }.to_not raise_error(ActiveRecord::RecordNotFound)
      end

      it 'redirects back' do
        post :destroy_guide, id: @guide.id
        expect(response).to redirect_to '/foo'
      end
    end

    describe 'POST #archive guide' do
      before :each do
        request.env['HTTP_REFERER'] = '/foo'
        @guide = create :guide, published: true
      end

      it 'sets guide publish to false' do
        post :archive_guide, id: @guide.id
        @guide.reload
        expect(@guide.published?).to be_false
      end

      it 'redirects back' do
        post :archive_guide, id: @guide.id
        expect(response).to redirect_to '/foo'
      end
    end

    describe 'GET #assign_guide' do
      before :each do
        @guide = create :guide, published: true
      end

      it 'sets the requested guide to @guide' do
        get :assign_guide, id: @guide.id
        expect(assigns(:guide)).to eq @guide
      end

      it 'redirects to tools when guide not found' do
        get :assign_guide, id: 10000
        expect(response).to redirect_to action: :tools
      end

      it 'renders the :assign_guide template' do
        get :assign_guide, id: @guide.id
        expect(response).to render_template :assign_guide
      end
    end

    describe 'POST #guide_update' do
      before :each do
        @guide = create :guide, published: true
      end

      it 'sets the requested guide to @guide' do
        get :guide_update, id: @guide.id
        expect(assigns(:guide)).to eq @guide
      end

      it 'shares the guide with the list of users' do
        get :guide_update, id: @guide.id, users: [@user.id]
        @user.reload
        expect(@user.guides.include? @guide).to be_true
      end

      it 'redirects to :assign_guide' do
        get :guide_update, id: @guide.id, users: [@user.id]
        expect(response).to redirect_to action: :assign_guide, id: @guide.id
      end
    end
  end
end