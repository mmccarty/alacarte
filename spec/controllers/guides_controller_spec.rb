require 'spec_helper'

describe GuidesController do
  describe 'guest access' do
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
    end

    describe 'GET #index' do
      it 'renders the :index view' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #show' do
      it 'renders the :show view' do
        guide = build :guide
        guide.create_home_tab
        @user.add_guide guide
        get :show, id: guide.id
        expect(response).to render_template :show
      end
    end
  end
end
