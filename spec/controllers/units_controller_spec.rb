require 'spec_helper'

describe UnitsController do
  describe 'guest access' do
    describe 'GET #add_modules' do
      it 'requires login' do
        get :add_modules
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #create' do
      it 'requires login' do
        post :create
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
  end

  describe 'author access' do
    before :each do
      @user = create :user
      session[:user_id] = @user.id

      @tutorial = create :tutorial
      @user.add_tutorial @tutorial
    end

    describe 'POST #create' do
      it 'creates a new unit' do
        post :create, tutorial_id: @tutorial.id, unit: { title: 'new unit' }
        expect(@tutorial.units[0].title).to eq 'new unit'
      end

      it 'redirects to edit the new unit' do
        post :create, tutorial_id: @tutorial.id, unit: { title: 'new unit' }
        expect(response).to redirect_to edit_tutorial_unit_path(@tutorial, @tutorial.units[0])
      end
    end

    describe 'GET #index' do
      it 'renders the :index template' do
        get :index, tutorial_id: @tutorial.id
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'renders the :new template' do
        get :new, tutorial_id: @tutorial.id
        expect(response).to render_template :new
      end
    end

    describe 'editing' do
      before :each do
        @unit = create :unit, created_by: @user.id
        @tutorial.add_units [@unit.id]
      end

      describe 'GET #add_modules' do
        it 'renders the :add_modules form' do
          Local.create
          get :add_modules, tutorial_id: @tutorial.id, id: @unit.id
          expect(response).to render_template :add_modules
        end
      end

      describe 'GET #edit' do
        it 'renders the :edit template' do
          get :edit, tutorial_id: @tutorial.id, id: @unit.id
          expect(response).to render_template :edit
        end
      end

      describe 'POST #update' do
        it 'saves changes to the unit' do
          post :update, tutorial_id: @tutorial.id, id: @unit.id, unit: { description: 'adding a description' }
          @unit.reload
          expect(@unit.description).to eq 'adding a description'
        end

        it 'saves changes to the tags' do
          post :update, tutorial_id: @tutorial.id, id: @unit.id, unit: { tag_list: 'this, that, the other' }
          expect(@unit.tags.map(&:name).sort).to eq ['that', 'the other', 'this']
        end

        it 'redirects to the list of units on save' do
          post :update, tutorial_id: @tutorial.id, id: @unit.id, commit: 'Save'
          expect(response).to redirect_to tutorial_units_path(@tutorial)
        end

        it 'redirects to the #add_modules page on request' do
          post :update, tutorial_id: @tutorial.id, id: @unit.id, commit: 'Save & Add Modules'
          expect(response).to redirect_to add_modules_tutorial_unit_path(@tutorial, @unit)
        end
      end
    end
  end
end
