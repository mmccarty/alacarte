require 'spec_helper'

describe TabsController do
  describe 'guest access' do
    describe 'GET #add_modules' do
      it 'requires login' do
        get :add_modules
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
      it 'adds modules to the session' do
        mod = create :miscellaneous_resource
        post :add_mod, mid1: mod.id, mid2: mod.class.name
        expect(session[:add_mods]).to eq ["#{ mod.id }#{ mod.class }"]
      end
    end

    describe 'GET #add_modules' do
      it 'renders the :add_modules view' do
        get :add_modules, guide_id: @guide.id, id: @tab.id
        expect(response).to render_template :add_modules
      end
    end

    describe 'POST #add_modules' do
      it 'adds modules from the session to the tab' do
        mod = create :miscellaneous_resource
        @user.create_and_add_resource mod
        session[:add_mods] = ["#{ mod.id }#{ mod.class }"]
        post :add_modules, guide_id: @guide.id, id: @tab.id
        expect(@tab.modules).to eq [mod]
      end
    end

    describe 'POST #remove_module' do
      before :each do
        @mod = create :miscellaneous_resource
        @user.create_and_add_resource @mod
        session[:add_mods] = ["#{ @mod.id }#{ @mod.class }"]
        post :add_modules, guide_id: @guide.id, id: @tab.id

        request.env['HTTP_REFERER'] = '/'
      end

      it 'removes the module from the tab' do
        post :remove_module, id: @tab.id, mod: @mod.id, type: @mod.class.to_s
        @tab.reload
        expect(@tab.modules.include? @mod).to be_false
      end

      it 'redirects :back' do
        post :remove_module, id: @tab.id, mod: @mod.id, type: @mod.class.to_s
        expect(response).to redirect_to '/'
      end

      it 'only removes one module when it has been added multiple times' do
        session[:add_mods] = ["#{ @mod.id }#{ @mod.class }"]
        post :add_modules, guide_id: @guide.id, id: @tab.id

        post :remove_module, id: @tab.id, mod: @mod.id, type: @mod.class.to_s
        @tab.reload
        expect(@tab.modules.include? @mod).to be_true
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

    describe 'POST #reorder_modules' do
      it 'rearranges modules to be in the specified order' do
        mods = 1.upto(4).map { create :miscellaneous_resource }
        res = mods.map { |mod| Resource.create mod: mod }
        res.each { |resource| @tab.add_resource resource }
        post :reorder_modules, guide_id: @guide.id, id: @tab.id, resource_ids: [res[2].id, res[0].id, res[3].id, res[1].id]
        expect(@tab.sorted_modules).to eq [mods[2], mods[0], mods[3], mods[1]]
      end

      it 'renders nothing' do
        mods = 1.upto(4).map { create :miscellaneous_resource }
        res = mods.map { |mod| Resource.create mod: mod }
        res.each { |resource| @tab.add_resource resource }
        post :reorder_modules, guide_id: @guide.id, id: @tab.id, resource_ids: [res[2].id, res[0].id, res[3].id, res[1].id]
        expect(response.body).to be_blank
      end

      it 'can specify left and right columns separately' do
        mods = 1.upto(4).map { create :miscellaneous_resource }
        res = mods.map { |mod| Resource.create mod: mod }
        res.each { |resource| @tab.add_resource resource }
        post :reorder_modules, guide_id: @guide.id, id: @tab.id, left_ids: [res[1].id, res[3].id], right_ids: [res[0].id, res[2].id]
        expect(@tab.sorted_modules).to eq [mods[1], mods[0], mods[3], mods[2]]
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
