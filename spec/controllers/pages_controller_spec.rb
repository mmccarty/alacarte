require 'spec_helper'

describe PagesController do
  describe 'guest access' do
    describe 'GET #copy' do
      it 'requires login' do
        get :copy
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #copy' do
      it 'requires login' do
        post :copy
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #create' do
      it 'requires login' do
        post :create
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #destroy' do
      it 'requires login' do
        post :destroy
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

    describe 'GET #publish' do
      it 'requires login' do
        get :publish
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

    describe 'GET #edit_contact' do
      it 'requires login' do
        get :edit_contact
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #edit_contact' do
      it 'requires login' do
        post :edit_contact
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #set_owner' do
      it 'requires login' do
        get :set_owner
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit_relateds' do
      it 'requires login' do
        get :edit_relateds
        expect(response).to redirect_to login_path
      end
    end

    describe 'PUT #edit_relateds' do
      it 'requires login' do
        put :edit_relateds
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #remove_related' do
      it 'requires login' do
        post :remove_related
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #archive' do
      it 'requires login' do
        post :archive
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #share' do
      it 'requires login' do
        get :share
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #share' do
      it 'requires login' do
        post :share
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #toggle_columns' do
      it 'requires login' do
        post :toggle_columns
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #sort_tabs' do
      it 'requires login' do
        post :sort_tabs
        expect(response).to redirect_to login_path
      end
    end
  end

  shared_examples 'individual page' do
    before :each do
      @page = create :page
      @user.add_page @page
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

    describe 'GET #copy' do
      it 'assigns a @page to be the origin page' do
        get :copy, id: @page.id
        expect(assigns(:item)).to eq @page
      end

      it 'renders the :copy template' do
        get :copy, id: @page.id
        expect(response).to render_template :copy
      end

    end

    describe 'GET #publish' do
      before :each do
        request.env['HTTP_REFERER'] = '/'
      end

      it 'toggles the value of the "published" flag' do
        @page.update_attribute :published, false
        get :publish, id: @page.id
        @page.reload
        expect(@page).to be_published
      end

      it 'redirect back to whence we came' do
        request.env['HTTP_REFERER'] = '/my/test/url'
        get :publish, id: @page.id
        expect(response).to redirect_to '/my/test/url'
      end

      it 'unarchives pages when they get published' do
        @page.update_attribute :published, false
        @page.update_attribute :archived, true
        get :publish, id: @page.id
        @page.reload
        expect(@page).to_not be_archived
      end

      it 'does not unarchive pages when they get unpublished' do
        @page.update_attribute :published, true
        @page.update_attribute :archived, true
        get :publish, id: @page.id
        @page.reload
        expect(@page).to be_archived
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

    describe 'GET #share' do
      it 'renders the :share template' do
        get :share, id: @page.id
        expect(response).to render_template :share
      end
    end

    describe 'POST #share' do
      it 'redirect to GET :share' do
        post :share, id: @page.id
        expect(response).to redirect_to polymorphic_path([@page], action: :share)
      end

      it 'shares the page without copying' do
        new_user = create :user
        post :share, id: @page.id, users: [new_user.id], copy: '0'
        @page.reload
        expect(@page.shared?).to be_true
      end

      it 'shares the page by copying creates a new page' do
        new_user = create :user
        expect {
          post :share, id: @page.id, users: [new_user.id], copy: '1'
        }.to change(Page, :count).by(1)
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

    describe 'POST #copy' do
      it 'creates a new page' do
        expect {
          post :copy, id: @page.id
        }.to change(Page, :count).by(1)
      end

      it 'redirects to the edit page for the new page' do
        post :copy, id: @page.id
        expect(response).to redirect_to edit_page_path(assigns(:new_item))
      end

      it 'makes copies of tabs for the new page' do
        post :copy, id: @page.id, options: 'copy'
        expect(assigns(:new_item).tabs).to_not be_empty
      end

      it 'does not remove tabs from the source page' do
        post :copy, id: @page.id, options: 'copy'
        @page.reload
        expect(@page.tabs).to_not be_empty
      end

      it 'adds the tabs to the new page instead of source page' do
        post :copy, id: @page.id, options: 'reuse'
        num_tabs_src = @page.tabs.length
        @page.reload
        expect(@page.tabs.length).to eq num_tabs_src
      end

      it 'makes copies of the tabs even when sharing the modules' do
        post :copy, id: @page.id, options: 'reuse'
        expect(assigns(:new_item).tabs).to_not be_empty
      end

      it 'does not remove tabs from the source page even when sharing the modules' do
        post :copy, id: @page.id, options: 'copy'
        @page.reload
        expect(@page.tabs).to_not be_empty
      end

      it 'will not create redundant home tabs' do
        post :copy, id: @page.id, options: 'copy'
        expect(assigns(:new_item).tabs.length).to eq @page.tabs.length
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

    describe 'GET #edit_contact' do
      it 'assigns the given page to @page' do
        get :edit_contact, id: @page.id
        expect(assigns(:page)).to_not be_nil
      end

      it "assigns the page's first tab to @tab" do
        get :edit_contact, id: @page.id
        expect(assigns(:tab)).to_not be_nil
      end

      it 'redirects pages_paths when the record is not found' do
        request.env['HTTP_REFERER'] = '/'
        get :edit_contact, id: 1000
        expect(response).to redirect_to pages_path
      end

      it 'renders :edit_contact on success' do
        get :edit_contact, id: @page.id
        expect(response).to render_template :edit_contact
      end
    end

    describe 'PUT #edit_contact' do
      before :each do
        @mod = create :inst_resource
      end

      it 'updates the page' do
        put :edit_contact, id: @page.id, page: {resource_id: @mod.id}
        @page.reload
        expect(@page.resource_id).to eq @mod.id
      end

      it 'redirects to show page' do
        put :edit_contact, id: @page.id, guide: {resource_id: @mod.id}
        expect(response).to redirect_to @page
      end
    end

    describe 'POST #set_owner' do
      before :each do
        @user2 = create :author
      end

      it 'assigns the given uid to @owner' do
        post :set_owner, id: @page.id, uid: @user2.id
        expect(assigns(:owner)).to eq @user2
      end

      it 'sets the created by of the page to the given owner' do
        post :set_owner, id: @page.id, uid: @user2.id
        @page.reload
        expect(@page.created_by).to eq @user2.name
      end

      it 'redirects to :share' do
        post :set_owner, id: @page.id, uid: @user2.id
        expect(response).to redirect_to action: :share
      end
    end

    describe 'GET #edit_relateds' do
      it 'assigns the first tab of the page to @tab' do
        get :edit_relateds, id: @page.id
        expect(assigns(:tab)).to eq @page.tabs.first
      end

      it 'assigns the published pages to @pages' do
        @guide = create :guide, published: true
        get :edit_relateds, id: @page.id
        expect(assigns(:guides)).to eq [@guide]
      end

      it 'renders the edit_relateds template' do
        get :edit_relateds, id: @page.id
        expect(response).to render_template :edit_relateds
      end
    end

    describe 'PUT #edit_relateds' do
      before :each do
        @guide = create :guide, published: true
      end

      it 'add related guides' do
        put :edit_relateds, id: @page.id, relateds: [@guide.id]
        @page.reload
        expect(@page.related_guides.include?(@guide)).to be_true
      end

      it 'redirects to show page' do
        put :edit_relateds, id: @page.id, relateds:  [@guide.id]
        expect(response).to redirect_to @page
      end
    end

    describe 'POST #remove_related' do
      before :each do
        @guide = create :guide, published: true
        @page.add_related_guides [@guide.id]
      end

      it 'removes the guide from the given pages related guides' do
        post :remove_related, id: @page.id, gid: @guide.id
        @page.reload
        expect(@page.related_guides.include?(@guide)).to be_false
      end

      it 'redirects to :edit_relateds' do
        post :remove_related, id: @page.id, gid: @guide.id
        expect(response).to redirect_to action: :edit_relateds
      end
    end

    describe 'GET #share' do
      it 'assigns the given item to @item' do
        get :share, id: @page.id
        expect(assigns(:item)).to_not be_nil
      end

      it 'assigns all the users to @user_list' do
        get :share, id: @page.id
        expect(assigns(:user_list)).to_not be_nil
      end

      it 'renders the share template' do
        get :share, id: @page.id
        expect(response).to render_template :share
      end
    end

    describe 'POST #archive' do
      before :each do
        request.env['HTTP_REFERER'] = '/'
        @page.published = true
        @page.save
      end

      it 'archives the given page' do
        post :archive, id: @page.id
        @page.reload
        expect(@page.archived?).to be_true
      end

      it 'unpublishes the given page' do
        post :archive, id: @page.id
        @page.reload
        expect(@page.published?).to be_false
      end

      it 'redirects back' do
        post :archive, id: @page.id
        expect(response).to redirect_to '/'
      end
    end
  end

  describe 'admin access' do
    before :each do
      @user = create :author
      @admin = create :admin
      session[:user_id] = @admin.id

      @subject = create :subject

      Local.create
    end

    it_behaves_like 'individual page'

    describe 'POST #create' do
      it 'creates a new page' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        expect {
          post :create, page: page
        }.to change(Page, :count).by(1)
      end

      it 'creates a default tab for the new page' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        post :create, page: page
        expect(@admin.pages.first.tabs).to_not be_empty
      end

      it 'sets the list of subjects for the new page' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        post :create, page: page
        expect(@admin.pages.first.subjects).to match_array [@subject]
      end

      it 'redirects to the :show view' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        post :create, page: page
        expect(response).to redirect_to @admin.pages.first
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

    it_behaves_like 'individual page'

    describe 'POST #create' do
      it 'creates a new page' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        expect {
          post :create, page: page
        }.to change(Page, :count).by(1)
      end

      it 'creates a default tab for the new page' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        post :create, page: page
        expect(@user.pages.first.tabs).to_not be_empty
      end

      it 'sets the list of subjects for the new page' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        post :create, page: page
        expect(@user.pages.first.subjects).to match_array [@subject]
      end

      it 'redirects to the :show view' do
        page = attributes_for :page
        page[:subject_ids] = [@subject.id]
        post :create, page: page
        expect(response).to redirect_to @user.pages.first
      end
    end

    describe 'GET #index' do
      it 'populates an array of pages' do
        page = create :page
        @user.add_page page
        get :index
        expect(assigns(:items)).to match_array [page]
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end
  end
end
