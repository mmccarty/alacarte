require 'spec_helper'

describe NodesController do
  describe 'guest access' do
    describe 'POST #copy' do
      it 'requires login' do
        post :copy
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit' do
      it 'requires login' do
        get :edit
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
      @mis = create :node
    end

    describe 'POST #copy' do
      it 'creates a new resource' do
        expect {
          post :copy, id: @mis.id
        }.to change(Node, :count).by(1)
      end

      it 'redirects to the edit page for the new resource' do
        post :copy, id: @mis.id
        expect(response).to redirect_to edit_node_path(assigns(:new_mod))
      end
    end

    describe 'PUT #update' do
      it 'updates attributes of the requested guide' do
        put :update, id: @mis.id, tag_list: 'this, that, the other'
        @mis.reload
        expect(@mis.tags.map(&:name).sort).to match_array ['that', 'the other', 'this']
      end

      it 'renders nothing' do
        put :update, id: @mis.id, module_title: 'timmeh!'
        expect(response).to render_template nil
      end
    end
  end
  describe 'for guests' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #new' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #manage' do
      it 'requires login' do
        get :manage
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_item' do
      it 'requires login' do
        post :add_item
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_guide' do
      it 'requires login' do
        post :add_to_guide
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_page' do
      it 'requires login' do
        post :add_to_page
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'for authors' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id

      Local.create
    end

    describe 'GET #index' do
      it 'renders the index view' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'renders the new module form' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create MiscellaneousResource' do
      before :each do
        @attrs = attributes_for :node
      end

      it 'creates a new module' do
        expect {
          post :create, @attrs
        }.to change(Node, :count).by(1)
      end

      it 'assigns the new module to :mod' do
        post :create, @attrs
        expect(assigns :mod).to_not be_blank
      end

      it 'assigns tags to the new module' do
        @attrs[:tag_list] = 'tags'
        post :create, @attrs
        expect(assigns(:mod).tag_list).to eq ['tags']
      end
    end

    describe 'GET #manage' do
      it 'renders the module management page' do
        request.env['HTTP_REFERER'] = '/'
        mod = create :node
        get :manage, id: mod.id
        expect(response).to render_template :manage
      end
    end

    describe 'POST #add_item' do
      it 'adds the guide/page to the session' do
        post :add_item, tid: 1
        expect(session[:tabs]).to eq ['1']
      end

      it 'can add multiple guides/pages' do
        post :add_item, tid: 1
        post :add_item, tid: 2
        expect(session[:tabs]).to eq ['1', '2']
      end

      it 'will not add the same guide/page multiple times' do
        post :add_item, tid: 1
        post :add_item, tid: 1
        expect(session[:tabs]).to eq ['1']
      end

      it 'renders nothing' do
        post :add_item, tid: 1
        expect(response.body).to be_blank
      end
    end

    describe 'GET #add_to_guide' do
      it 'renders the :add_to_item view' do
        mod = create :node
        get :add_to_guide, id: mod.id
        expect(response).to render_template :add_to_item
      end
    end

    describe 'POST #add_to_guide' do
      before :each do
        @mod = create :node
        @user.create_and_add_node @mod

        @tab = build :tab
        guide = create :guide
        guide.add_tab @tab

        session[:tabs] = [@tab.id.to_s]
      end

      it 'adds the module to guides from the session' do
        post :add_to_guide, id: @mod.id
        expect(@tab.nodes).to eq [@mod]
      end

      it 'redirects to the module management page' do
        post :add_to_guide, id: @mod.id
        expect(response).to redirect_to manage_node_path(@mod)
      end
    end

    describe 'GET #add_to_page' do
      it 'renders the :add_to_page view' do
        mod = create :node
        get :add_to_page, id: mod.id
        expect(response).to render_template :add_to_item
      end
    end

    describe 'POST #add_to_page' do
      before :each do
        @mod = create :node
        @user.create_and_add_node @mod

        @tab = build :tab
        page = create :page
        page.add_tab @tab

        session[:tabs] = [@tab.id.to_s]
      end

      it 'adds pages from the session to the module' do
        post :add_to_page, id: @mod.id
        expect(@tab.nodes).to eq [@mod]
      end

      it 'redirects to the module management page' do
        post :add_to_page, id: @mod.id
        expect(response).to redirect_to manage_node_path(@mod)
      end
    end
  end
end
