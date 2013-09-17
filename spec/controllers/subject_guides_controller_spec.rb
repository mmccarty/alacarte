require 'spec_helper'

describe SubjectGuidesController do
  before :each do
    @guide = create :guide, tag_list: 'test'
    Local.create
  end

  describe 'GET #show' do
    it 'responds successfully with an HTTP 200 status code' do
      get :show, id: @guide.id
      expect(response).to be_success
      expect(response.status).to eq 200
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
      expect(assigns(:mods)).to match_array tab.sorted_nodes
    end

    it 'constructs lists of modules for the left and right columns' do
      tab = @guide.tabs.first
      get :show, id: @guide.id
      expect(assigns(:mods_left)).to match_array tab.left_nodes
      expect(assigns(:mods_right)).to match_array tab.right_nodes
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
      expect(assigns(:mods_left)).to be_empty
      expect(assigns(:mods_right)).to be_empty
    end
  end

  describe 'GET #index' do
    before :each do
      @guide.published = true
      @guide.save
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :published_pages template' do
      get :index
      expect(response).to render_template :index
    end

    it 'assigns published guides to @guide' do
      get :index
      expect(assigns(:guides)).to eq [@guide]
    end

    it 'assigns tags and counts to @tags' do
      get :index
      expect(assigns(:tags)).to_not be_nil
      expect(assigns(:tags).empty?).to be_false
    end
  end

  describe 'GET #tagged' do
    before :each do
      @guide.published = true
      @guide.save
    end

    it 'responds successfully with an HTTP 200 status code' do
      post :tagged, id: 'test'
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :tagged template' do
      post :tagged, id: 'test'
      expect(response).to render_template :tagged
    end

    it 'assigns a list of published guides to @guides' do
      post :tagged, id: 'test'
      expect(assigns(:guides).empty?).to be_false
    end
  end

  describe 'GET #feed' do
    it 'assigns the guide to @guide' do
      get :feed, id: @guide.id, format: :xml
      expect(assigns(:guide)).to_not be_nil
    end
  end
end
