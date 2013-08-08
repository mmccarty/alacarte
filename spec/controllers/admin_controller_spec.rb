require 'spec_helper'

describe AdminController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #auto_archive' do
      it 'requires login' do
        post :auto_archive
        expect(response).to redirect_to login_path
      end
    end

    shared_examples 'guest access' do |thing|
      describe "GET ##{ thing }s" do
        it 'requires login' do
          get "#{ thing }s"
          expect(response).to redirect_to login_path
        end
      end

      describe "POST #destroy_#{ thing }" do
        it 'requires login' do
          post "destroy_#{ thing }"
          expect(response).to redirect_to login_path
        end
      end

      describe "POST #archive_#{ thing }" do
        it 'requires login' do
          post "archive_#{ thing }"
          expect(response).to redirect_to login_path
        end
      end

      describe "GET #assign_#{ thing }" do
        it 'requires login' do
          get "assign_#{ thing }"
          expect(response).to redirect_to login_path
        end
      end

      describe "POST ##{ thing }_update" do
        it 'requires login' do
          post "#{ thing }_update"
          expect(response).to redirect_to login_path
        end
      end

      describe "POST #remove_user_from_#{ thing }" do
        it 'requires login' do
          post "remove_user_from_#{ thing }"
          expect(response).to redirect_to login_path
        end
      end

    end

    %w(guide page tutorial).each do |thing|
      it_behaves_like 'guest access', thing
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

    shared_examples 'a guide, page, or tutorial' do |thing|
      describe "GET ##{ thing }s" do
        before :each do
          @thing = create thing
          @thing.share @user, nil
        end

        it 'sets requested user to @user' do
          get "#{ thing }s", id: @user.id
          expect(assigns(:user)).to eq @user
        end

        it "sets @#{ thing }s to the requested user's #{ thing }" do
          get "#{ thing }s", id: @user.id
          expect(assigns("#{ thing }s")).to eq @user.send "#{ thing }s"
        end

        it "sets #{ thing } count to @count" do
          get "#{ thing }s", id: @user.id
          expect(assigns(:count)).to eq @user.send("#{ thing }s").size
        end

        it "renders the :#{ thing } template" do
          get "#{ thing }s", id: @user.id
          expect(response).to render_template thing
        end
      end

      describe "POST #destroy_#{ thing }" do
        before :each do
          @author = create :author
          session[:author] = @author.id
          @thing = create thing
          @thing.share @author, nil
          request.env['HTTP_REFERER'] = '/foo'
        end

        it "deletes the #{ thing } when there is one owner" do
          post "destroy_#{ thing }", id: @thing.id
          expect {
            @thing.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'just deletes the association when there is more than one owner' do
          @thing.share @user, nil
          post "destroy_#{ thing }", id: @thing.id
          expect {
            @thing.reload
          }.to_not raise_error(ActiveRecord::RecordNotFound)
        end

        it 'redirects back' do
          post "destroy_#{ thing }", id: @thing.id
          expect(response).to redirect_to '/foo'
        end
      end

      describe "POST #archive #{ thing }" do
        before :each do
          request.env['HTTP_REFERER'] = '/foo'
          @thing = create thing, published: true
        end

        it "sets #{ thing } publish to false" do
          post "archive_#{ thing }", id: @thing.id
          @thing.reload
          expect(@thing.published?).to be_false
        end

        it 'redirects back' do
          post "archive_#{ thing }", id: @thing.id
          expect(response).to redirect_to '/foo'
        end
      end

      describe "GET #assign_#{ thing }" do
        before :each do
          @thing = create thing, published: true
        end

        it "sets the requested #{ thing } to @#{ thing }" do
          get "assign_#{ thing }", id: @thing.id
          expect(assigns(thing)).to eq @thing
        end

        it "redirects to tools when #{ thing } not found" do
          get "assign_#{ thing }", id: 10000
          expect(response).to redirect_to action: :tools
        end

        it "renders the :assign_#{ thing } template" do
          get "assign_#{ thing }", id: @thing.id
          expect(response).to render_template "assign_#{ thing }"
        end
      end

      describe "POST ##{ thing }_update" do
        before :each do
          @thing = create thing, published: true
        end

        it "sets the requested #{ thing } to @#{ thing }" do
          get "#{ thing }_update", id: @thing.id
          expect(assigns(thing)).to eq @thing
        end

        it "shares the #{ thing } with the list of users" do
          get  "#{ thing }_update", id: @thing.id, users: [@user.id]
          @user.reload
          expect(@user.send("#{ thing }s").include? @thing).to be_true
        end

        it "redirects to :assign_#{ thing }" do
          get  "#{ thing }_update", id: @thing.id, users: [@user.id]
          expect(response).to redirect_to action: "assign_#{ thing }", id: @thing.id
        end
      end

      describe "POST #remove_user_from_#{ thing }" do
        before :each do
          @author = create :author
          @thing = create thing, published: true
          @thing.share @author, nil
        end

        it "sets the requested #{ thing } to @#{ thing }" do
          get "remove_user_from_#{ thing }", id: @thing.id, uid: @author.id
          expect(assigns(thing)).to eq @thing
        end

        it 'redirects to :tools when guide not found' do
          get "remove_user_from_#{ thing }", id: 10000, uid: @author.id
          expect(response).to redirect_to action: :tools, list: :mine
        end

        it 'removes the user from the guide' do
          get "remove_user_from_#{ thing }", id: @thing.id, uid: @author.id
          @author.reload
          expect(@author.guides).to be_empty
        end

        it "redirects to :assign_#{ thing } on success" do
          get "remove_user_from_#{ thing }", id: @thing.id, uid: @author.id
          expect(response).to redirect_to action: "assign_#{ thing }", id: @thing
        end
      end
    end

    %w(guide page tutorial).each do |thing|
      it_behaves_like 'a guide, page, or tutorial', thing
    end

    context 'customizations' do
      before :each do
        @local = create :local
      end

      describe 'GET #customize_layout' do
        it 'renders :customize_layout template' do
          get :customize_layout
          expect(response).to render_template :customize_layout
        end
      end

      describe 'POST #customize_layout' do
        it 'updates the @local object' do
          post :customize_layout, local: {ica_page_title: 'Stupid Class!'}
          @local.reload
          expect(@local.ica_page_title).to eq 'Stupid Class!'
        end
      end

      describe 'GET #customize_content_types' do
        it 'sets @selected' do
          get :customize_content_types
          expect(assigns(:selected)).to_not be_nil
        end

        it 'renders :customize_content_types template' do
          get :customize_content_types
          expect(response).to render_template :customize_content_types
        end
      end

      describe 'POST #customize_content_types' do
        it 'updates the @local object' do
          post :customize_content_types, local: {types: 'page'}
          @local.reload
          expect(@local.types).to eq 'page'
        end
      end

      describe 'GET #customize_admin_email' do
        it 'renders :customize_admin_email template' do
          get :customize_admin_email
          expect(response).to render_template :customize_admin_email
        end
      end

      describe 'POST #customize_admin_email' do
        it 'updates the @local object' do
          post :customize_admin_email, local: {admin_email_to: 'foo@bar.com'}
          @local.reload
          expect(@local.admin_email_to).to eq 'foo@bar.com'
        end
      end
    end
  end
end