require 'spec_helper'

describe TutorialsController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #add_units' do
      it 'requires login' do
        get :add_units
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #add_to_list' do
      it 'requires login' do
        post :add_to_list
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id

      @tutorial = create :tutorial
      @user.add_tutorial @tutorial
    end

    describe 'GET #index' do
      it 'renders the list of tutorials' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #add_units' do
      it 'renders the add-units form' do
        get :add_units, id: @tutorial.id
        expect(response).to render_template :add_units
      end
    end

    describe 'POST #add_to_list' do
      it 'adds the unit id to the session' do
        unit = create :unit
        post :add_to_list, id: @tutorial.id, uid: unit.id
        expect(session[:added]).to eq [unit.id.to_s]
      end
    end

    describe 'POST #add_units' do
      it 'adds units from the session to the tutorial' do
        unit = create :unit
        post :add_to_list, id: @tutorial.id, uid: unit.id
        post :add_units, id: @tutorial.id
        expect(@tutorial.units).to eq [unit]
      end
    end
  end
end
