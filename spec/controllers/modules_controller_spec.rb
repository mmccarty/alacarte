require 'spec_helper'

describe ModulesController do
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

    describe 'POST #add_tutorial' do
      it 'requires login' do
        post :add_tutorial
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_tutorial' do
      it 'requires login' do
        post :add_to_tutorial
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

    describe 'POST #create' do
      it 'requires the user to specify the module type' do
        post :create, mod: { type: '' }
        expect(response).to render_template :new
      end
    end

    describe 'GET #manage' do
      it 'renders the module management page' do
        request.env['HTTP_REFERER'] = '/'
        mod = create :miscellaneous_resource
        get :manage, id: mod.id, type: mod.class.name
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
        mod = create :miscellaneous_resource
        get :add_to_guide, id: mod.id, type: mod.class.name
        expect(response).to render_template :add_to_item
      end
    end

    describe 'POST #add_to_guide' do
      before :each do
        @mod = create :miscellaneous_resource
        @user.create_and_add_resource @mod

        @tab = build :tab
        guide = create :guide
        guide.add_tab @tab

        session[:tabs] = [@tab.id.to_s]
      end

      it 'adds the module to guides from the session' do
        post :add_to_guide, id: @mod.id, type: @mod.class.name
        expect(@tab.modules).to eq [@mod]
      end

      it 'redirects to the module management page' do
        post :add_to_guide, id: @mod.id, type: @mod.class.name
        expect(response).to redirect_to manage_module_path(@mod, type: @mod.class)
      end
    end

    describe 'GET #add_to_page' do
      it 'renders the :add_to_page view' do
        mod = create :miscellaneous_resource
        get :add_to_page, id: mod.id, type: mod.class.name
        expect(response).to render_template :add_to_item
      end
    end

    describe 'POST #add_to_page' do
      before :each do
        @mod = create :miscellaneous_resource
        @user.create_and_add_resource @mod

        @tab = build :tab
        page = create :page
        page.add_tab @tab

        session[:tabs] = [@tab.id.to_s]
      end

      it 'adds pages from the session to the module' do
        post :add_to_page, id: @mod.id, type: @mod.class.name
        expect(@tab.modules).to eq [@mod]
      end

      it 'redirects to the module management page' do
        post :add_to_page, id: @mod.id, type: @mod.class.name
        expect(response).to redirect_to manage_module_path(@mod, type: @mod.class)
      end
    end

    describe 'POST #add_tutorial' do
      it 'adds the tutorial to the session' do
        post :add_tutorial, tid: 1
        expect(session[:units]).to eq ['1']
      end

      it 'renders nothing' do
        post :add_tutorial, tid: 1
        expect(response.body).to be_blank
      end
    end

    describe 'GET #add_to_tutorial' do
      it 'renders the :add_to_tutorial view' do
        mod = create :miscellaneous_resource
        get :add_to_tutorial, id: mod.id, type: mod.class.name
        expect(response).to render_template :add_to_tutorial
      end
    end

    describe 'POST #add_to_tutorial' do
      before :each do
        @mod = create :miscellaneous_resource
        @user.create_and_add_resource @mod

        @unit = create :unit
        tutorial = create :tutorial
        tutorial.add_units [@unit.id]

        session[:units] = [@unit.id.to_s]
      end

      it 'adds tutorials from the session to the module' do
        post :add_to_tutorial, id: @mod.id, type: @mod.class.name
        expect(@unit.modules).to eq [@mod]
      end

      it 'redirects to the module management page' do
        post :add_to_tutorial, id: @mod.id, type: @mod.class.name
        expect(response).to redirect_to manage_module_path(@mod, type: @mod.class)
      end
    end
  end
end
