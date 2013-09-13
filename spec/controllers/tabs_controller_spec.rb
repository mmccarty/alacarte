require 'spec_helper'

describe TabsController do
  describe 'guest access' do
    describe 'GET #add_nodes' do
      it 'requires login' do
        get :add_nodes
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #show' do
      it 'requires login' do
        get :show
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id

      @guide = build :guide
      @user.add_guide @guide

      @tab = @guide.tabs.first

      Local.create
    end

    describe 'POST #add_mod' do
      it 'adds nodes to the session' do
        mod = create :node
        post :add_mod, mid1: mod.id, mid2: mod.class.name
        expect(session[:add_mods]).to eq ["#{ mod.id }#{ mod.class }"]
      end
    end

    describe 'GET #add_nodes' do
      it 'renders the :add_nodes view' do
        get :add_nodes, guide_id: @guide.id, id: @tab.id
        expect(response).to render_template :add_nodes
      end
    end

    describe 'POST #add_nodes' do
      it 'adds nodes from the session to the tab' do
        mod = create :node
        @user.create_and_add_node mod
        session[:add_mods] = [mod.id.to_s]
        post :add_nodes, guide_id: @guide.id, id: @tab.id
        expect(@tab.nodes).to eq [mod]
      end
    end

    describe 'POST #remove_node' do
      before :each do
        @mod = create :node
        @user.create_and_add_node @mod
        session[:add_mods] = [@mod.id.to_s]
        post :add_nodes, guide_id: @guide.id, id: @tab.id

        request.env['HTTP_REFERER'] = '/'
      end

      it 'removes the node from the tab' do
        post :remove_node, id: @tab.id, mod: @mod.id
        @tab.reload
        expect(@tab.nodes).to_not include @mod
      end

      it 'redirects :back' do
        post :remove_node, id: @tab.id, mod: @mod.id
        expect(response).to redirect_to '/'
      end

      it 'only removes one node when it has been added multiple times' do
        session[:add_mods] = [@mod.id.to_s]
        post :add_nodes, guide_id: @guide.id, id: @tab.id

        post :remove_node, id: @tab.id, mod: @mod.id
        @tab.reload
        expect(@tab.nodes).to include @mod
      end
    end

    describe 'POST #delete' do
      it 'destroys the tab' do
        tab = build :tab
        @guide.add_tab tab
        expect {
          post :delete, guide_id: @guide.id, id: tab.id
        }.to change(Tab, :count).by(-1)
      end

      it 'removes the tab from its parent' do
        @guide.add_tab(build :tab)
        post :delete, guide_id: @guide.id, id: @tab.id
        @guide.reload
        expect(@guide.tabs).to_not include @tab
      end

      it 'will not remove the last tab from a container' do
        post :delete, guide_id: @guide.id, id: @tab.id
        @guide.reload
        expect(@guide.tabs).to include @tab
      end

      it 'will report an error when attempting to remove the last tab' do
        post :delete, guide_id: @guide.id, id: @tab.id
        expect(flash[:error]).to be_present
      end

      it 'redirects to its parent' do
        tab = build :tab
        @guide.add_tab tab
        post :delete, guide_id: @guide.id, id: @tab.id
        expect(response).to redirect_to @guide
      end
    end

    describe 'POST #reorder_nodes' do
      it 'rearranges nodes to be in the specified order' do
        mods = 1.upto(4).map { create :node }
        mods.each { |node| @tab.add_node node }
        post :reorder_nodes, guide_id: @guide.id, id: @tab.id, resource_ids: [mods[2].id, mods[0].id, mods[3].id, mods[1].id]
        expect(@tab.sorted_nodes).to eq [mods[2], mods[0], mods[3], mods[1]]
      end

      it 'renders nothing' do
        mods = 1.upto(4).map { create :node }
        mods.each { |node| @tab.add_node node }
        post :reorder_nodes, guide_id: @guide.id, id: @tab.id, resource_ids: [mods[2].id, mods[0].id, mods[3].id, mods[1].id]
        expect(response.body).to be_blank
      end

      it 'can specify left and right columns separately' do
        mods = 1.upto(4).map { create :node }
        mods.each { |node| @tab.add_node node }
        post :reorder_nodes, guide_id: @guide.id, id: @tab.id, left_ids: [mods[1].id, mods[3].id], right_ids: [mods[0].id, mods[2].id]
        expect(@tab.sorted_nodes).to eq [mods[1], mods[0], mods[3], mods[2]]
      end
    end

    describe 'POST #save_tab_name' do
      it 'sets the tab name' do
        post :save_tab_name, guide_id: @guide.id, id: @tab.id, value: "I'm a tab!"
        @tab.reload
        expect(@tab.tab_name).to eq "I'm a tab!"
      end

      it 'renders a json response' do
        post :save_tab_name, guide_id: @guide.id, id: @tab.id, value: "I'm a tab!"
        expect(response.body).to eq "I'm a tab!"
      end
    end

    describe 'GET #show' do
      it 'sets the active tab in the session' do
        get :show, guide_id: @guide.id, id: @tab.id
        expect(session[:current_tab]).to eq @tab.id
      end

      it 'redirects to the containing guide' do
        get :show, guide_id: @guide.id, id: @tab.id
        expect(response).to redirect_to @guide
      end

      it 'redirects to the containing page' do
        page = build :page
        @user.add_page page
        tab = page.tabs.first
        get :show, page_id: page.id, id: tab.id
        expect(response).to redirect_to page
      end
    end

    describe 'POST #toggle_columns' do
      it 'changes a two-column layout into a one-column layout' do
        post :toggle_columns, guide_id: @guide.id, id: @tab.id
        @tab.reload
        expect(@tab.num_columns).to eq 1
      end

      it 'changes a one-column layout into a two-column layout' do
        @tab.update_attribute :template, 1
        post :toggle_columns, guide_id: @guide.id, id: @tab.id
        @tab.reload
        expect(@tab.num_columns).to eq 2
      end

      it 'redirect to the parent page' do
        post :toggle_columns, guide_id: @guide.id, id: @tab.id
        expect(response).to redirect_to @guide
      end
    end

    describe 'POST #delete' do
      it 'redirect to the parent page' do
        post :delete, guide_id: @guide.id, id: @tab.id
        expect(response).to redirect_to @guide
      end
    end
  end
end
