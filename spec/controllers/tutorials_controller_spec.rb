require 'spec_helper'

describe TutorialController do
  describe 'guest access' do
    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #units' do
      it 'requires login' do
        get :units
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

    describe 'GET #new_unit' do
      it 'requires login' do
        get :new_unit
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #create_unit' do
      it 'requires login' do
        get :create_unit
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit_unit' do
      it 'requires login' do
        get :edit_unit
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #add_modules' do
      it 'requires login' do
        get :add_modules
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

    describe 'GET #units' do
      it 'renders the list of units' do
        get :units, id: @tutorial.id
        expect(response).to render_template :units
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

    describe 'GET #new_unit' do
      it 'renders the :new_unit form' do
        get :new_unit, id: @tutorial.id
        expect(response).to render_template :new_unit
      end
    end

    describe 'POST #create_unit' do
      it 'creates a new unit' do
        post :create_unit, id: @tutorial.id, unit: { title: 'new unit' }
        expect(@tutorial.units[0].title).to eq 'new unit'
      end

      it 'redirects to edit the new unit' do
        post :create_unit, id: @tutorial.id, unit: { title: 'new unit' }
        expect(response).to redirect_to edit_unit_path(@tutorial, unit: @tutorial.units[0])
      end
    end

    describe 'unit editing' do
      before :each do
        @unit = create :unit, created_by: @user.id
        @tutorial.add_units [@unit.id]
      end

      describe 'GET #edit_unit' do
        it 'renders the edit form' do
          get :edit_unit, id: @tutorial.id, unit: @unit.id
          expect(response).to render_template :edit_unit
        end
      end

      describe 'POST #edit_unit' do
        it 'saves changes to the unit' do
          post :edit_unit, id: @tutorial.id, unit: { id: @unit.id, description: 'adding a description' }
          expect(@tutorial.units[0].description).to eq 'adding a description'
        end

        it 'redirects to the list of units on save' do
          post :edit_unit, id: @tutorial.id, unit: { id: @unit.id }, commit: 'Save'
          expect(response).to redirect_to units_path(@tutorial)
        end

        it 'redirects to the #add_modules page on request' do
          post :edit_unit, id: @tutorial.id, unit: { id: @unit.id }, commit: 'Save & Add Modules'
          expect(response).to redirect_to "/tutorial/add_modules/#{ @tutorial.to_param }?unit=#{ @unit.id }"
        end
      end

      describe 'GET #add_modules' do
        it 'renders the :add_modules form' do
          get :add_modules, id: @tutorial.id, unit: @unit.id
          expect(response).to render_template :add_modules
        end
      end
    end
  end
end
