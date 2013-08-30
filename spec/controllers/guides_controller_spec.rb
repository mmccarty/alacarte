require 'spec_helper'

describe GuidesController do
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

    describe 'POST #remove_user_from_guide' do
      it 'requires login' do
        post :remove_user_from_guide
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


  shared_examples 'individual guide' do
    before :each do
      @guide = create :guide
      @user.add_guide @guide
    end

    describe 'GET #copy' do
      it 'assigns @guide to be the original guide' do
        get :copy, id: @guide.id
        expect(assigns(:item)).to eq @guide
      end

      it 'renders the :copy template' do
        get :copy, id: @guide.id
        expect(response).to render_template :copy
      end
    end

    describe 'POST #copy' do
      it 'creates a new guide' do
        expect {
          post :copy, id: @guide.id
        }.to change(Guide, :count).by(1)
      end

      it 'redirects to the edit page for the new guide' do
        post :copy, id: @guide.id
        expect(response).to redirect_to edit_guide_path(assigns(:new_item))
      end

      it 'makes copies of tabs for the new guide' do
        post :copy, id: @guide.id, options: 'copy'
        expect(assigns(:new_item).tabs).to_not be_empty
      end

      it 'does not remove tabs from the source guide' do
        post :copy, id: @guide.id, options: 'copy'
        @guide.reload
        expect(@guide.tabs).to_not be_empty
      end

      it 'adds the tabs to the new guide instead of the source guide' do
        post :copy, id: @guide.id, options: 'reuse'
        num_tabs_src = @guide.tabs.length
        @guide.reload
        expect(@guide.tabs.length).to eq num_tabs_src
      end

      it 'makes copies of the tabs even when sharing the modules' do
        post :copy, id: @guide.id, options: 'reuse'
        expect(assigns(:new_item).tabs).to_not be_empty
      end

      it 'does not remove tabs from the source guide even when sharing the modules' do
        post :copy, id: @guide.id, options: 'copy'
        @guide.reload
        expect(@guide.tabs).to_not be_empty
      end

      it 'will not create redundant home tabs' do
        post :copy, id: @guide.id, options: 'copy'
        expect(assigns(:new_item).tabs.length).to eq @guide.tabs.length
      end
    end

    describe 'POST #destroy' do
      it 'deletes the guide' do
        expect {
          post :destroy, id: @guide.id
        }.to change(Guide, :count).by(-1)
      end

      it 'returns success' do
        post :destroy, id: @guide.id
        expect(response).to be_success
      end

      it 'renders nothing' do
        post :destroy, id: @guide.id
        expect(response.body).to be_blank
      end
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

    describe 'GET #publish' do
      it 'toggles the value of the "published" flag' do
        request.env['HTTP_REFERER'] = '/'
        @guide.update_attribute :published, false
        get :publish, id: @guide.id
        @guide.reload
        expect(@guide).to be_published
      end

      it 'redirect back to whence we came' do
        request.env['HTTP_REFERER'] = '/my/test/url'
        get :publish, id: @guide.id
        expect(response).to redirect_to '/my/test/url'
      end
    end

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

    it 'saves the current tab in the session' do
      get :show, id: @guide.id
      expect(session[:current_tab]).to eq @guide.tabs.first.id
    end

    it 'gracefully defaults to the first tab when the current tab is invalid' do
      session[:current_tab] = @guide.tabs.first.id + 1
      get :show, id: @guide.id
      expect(session[:current_tab]).to eq @guide.tabs.first.id
    end

    describe 'POST #sort_tabs' do
      it 'rearranges tabs to be in the specified order' do
        3.times { @guide.add_tab(build :tab) }
        tabs = @guide.tabs.clone
        post :sort_tabs, tab_ids: [tabs[2].id, tabs[0].id, tabs[3].id, tabs[1].id]
        @guide.reload
        expect(@guide.tabs).to eq [tabs[2], tabs[0], tabs[3], tabs[1]]
      end

      it 'renders nothing' do
        3.times { @guide.add_tab(build :tab) }
        tabs = @guide.tabs.clone
        post :sort_tabs, tab_ids: [tabs[2].id, tabs[0].id, tabs[3].id, tabs[1].id]
        expect(response.body).to be_blank
      end
    end

    describe 'POST #share' do
      it 'redirect to GET :share' do
        post :share, id: @guide.id
        expect(response).to redirect_to polymorphic_path([@guide], action: :share)
      end

      it 'shares the guide without copying' do
        new_user = create :user
        post :share, id: @guide.id, users: [new_user.id], copy: '0'
        @guide.reload
        expect(@guide.shared?).to be_true
      end

      it 'shares the guide by copying creates a new page' do
        new_user = create :user
        expect {
          post :share, id: @guide.id, users: [new_user.id], copy: '1'
        }.to change(Guide, :count).by(1)
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

    describe 'POST #remove_user_from_guide' do
      it 'removes the user from a guide' do
        user = @guide.users.first
        post :remove_user_from_guide, id: @guide.id, user: user.id
        @guide.reload
        expect(@guide.users.include? user ).to be_false
      end

      it 'redirects to share guide' do
        user = @guide.users.first
        post :remove_user_from_guide, id: @guide.id, user: user.id
        expect(response).to redirect_to polymorphic_path([@guide], action: :share)
      end
    end

    describe 'POST #create' do
      before :each do
        @guide_attrs = attributes_for(:guide)
        @guide_attrs[:master_ids] = []
        @guide_attrs[:subject_ids] = []
      end

      it 'creates a new guide' do

        expect {
          post :create, guide: @guide_attrs
        }.to change(Guide, :count).by(1)
      end

      it 'creates a default tab for the new guide' do
        post :create, guide: @guide_attrs
        expect(@user.guides.first.tabs).to_not be_empty
      end

      it 'redirects to the :show view' do
        post :create, guide: @guide_attrs
        expect(response).to redirect_to assigns :guide
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

      it 'assigns the user.id to user_id when given' do
        get :new, user_id: @user.id
        expect(session[:item_user_id]).to eq @user.id.to_s
      end
    end

    describe 'GET #edit_contact' do
      it 'assigns the given guide to @guide' do
        get :edit_contact, id: @guide.id
        expect(assigns(:guide)).to_not be_nil
      end

      it "assigns the guide's first tab to @tab" do
        get :edit_contact, id: @guide.id
        expect(assigns(:tab)).to_not be_nil
      end

      it 'redirects guides_paths when the record is not found' do
        request.env['HTTP_REFERER'] = '/'
        get :edit_contact, id: 1000
        expect(response).to redirect_to guides_path
      end

      it 'renders :edit_contact on success' do
        get :edit_contact, id: @guide.id
        expect(response).to render_template :edit_contact
      end
    end

    describe 'PUT #edit_contact' do
      before :each do
        @mod = create :inst_resource
      end

      it 'updates the guide' do
        put :edit_contact, id: @guide.id, guide: {resource_id: @mod.id}
        @guide.reload
        expect(@guide.resource_id).to eq @mod.id
      end

      it 'redirects to show guide' do
        put :edit_contact, id: @guide.id, guide: {resource_id: @mod.id}
        expect(response).to redirect_to @guide
      end
    end

    describe 'POST #set_owner' do
      before :each do
        @user2 = create :author
      end

      it 'assigns the given uid to @owner' do
        post :set_owner, id: @guide.id, uid: @user2.id
        expect(assigns(:owner)).to eq @user2
      end

      it 'sets the created by of the guide to the given owner' do
        post :set_owner, id: @guide.id, uid: @user2.id
        @guide.reload
        expect(@guide.created_by).to eq @user2.name
      end

      it 'redirects to :share' do
        post :set_owner, id: @guide.id, uid: @user2.id
        expect(response).to redirect_to action: :share
      end
    end

    describe 'GET #edit_relateds' do
      it 'assigns the first tab of the guide to @tab' do
        get :edit_relateds, id: @guide.id
        expect(assigns(:tab)).to eq @guide.tabs.first
      end

      it 'assigns the published guides to @guides' do
        @guide.published = true
        @guide.save
        get :edit_relateds, id: @guide.id
        expect(assigns(:guides)).to eq [@guide]
      end

      it 'renders the edit_relateds template' do
        get :edit_relateds, id: @guide.id
        expect(response).to render_template :edit_relateds
      end
    end

    describe 'PUT #edit_relateds' do
      before :each do
        @guide2 = create :guide, published: true
      end

      it 'add related guides' do
        put :edit_relateds, id: @guide.id, relateds: [@guide2.id]
        @guide.reload
        expect(@guide.related_guides.include?(@guide2)).to be_true
      end

      it 'redirects to show guide' do
        put :edit_relateds, id: @guide.id, relateds:  [@guide2.id]
        expect(response).to redirect_to @guide
      end
    end

    describe 'POST #remove_related' do
      before :each do
        @guide2 = create :guide, published: true
        @guide.add_related_guides [@guide2.id]
      end

      it 'removes the guide from the given guides related guides' do
        post :remove_related, id: @guide.id, gid: @guide2.id
        @guide.reload
        expect(@guide.related_guides.include?(@guide2)).to be_false
      end

      it 'redirects to :edit_relateds' do
        post :remove_related, id: @guide.id, gid: @guide2.id
        expect(response).to redirect_to action: :edit_relateds
      end
    end

    describe 'GET #share' do
      it 'assigns the given item to @item' do
        get :share, id: @guide.id
        expect(assigns(:item)).to_not be_nil
      end

      it 'assigns all the users to @user_list' do
        get :share, id: @guide.id
        expect(assigns(:user_list)).to_not be_nil
      end

      it 'renders the share template' do
        get :share, id: @guide.id
        expect(response).to render_template :share
      end
    end

  end

  describe 'admin access' do
    before :each do
      @user = create :author
      @admin = create :admin
      session[:user_id] = @admin.id
      session[:item_user_id] = @user.id
    end

    it_behaves_like 'individual guide'
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id
    end

    it_behaves_like 'individual guide'

    describe 'GET #index' do
      it 'populates an array of guides' do
        guide = create :guide
        @user.add_guide guide
        get :index
        expect(assigns(:items)).to match_array [guide]
      end

      it 'renders the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end
  end
end
