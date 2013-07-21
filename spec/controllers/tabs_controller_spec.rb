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
      @guide.create_home_tab
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

    describe 'GET #show' do
      it 'set the active tab in the session' do
        get :show, guide_id: @guide.id, id: @tab.id
        expect(session[:current_tab]).to eq @tab.id
      end

      it 'redirects to the guide' do
        get :show, guide_id: @guide.id, id: @tab.id
        expect(response).to redirect_to @guide
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

      it 'renders nothing' do
        post :toggle_columns, guide_id: @guide.id, id: @tab.id
        expect(response.body).to be_blank
      end
    end
  end
end
