require 'spec_helper'

describe ApplicationController do
  before(:each) { @app = ApplicationController.new }

  it 'should create module objects by type' do
    mod = @app.create_module_object 'MiscellaneousResource'
    expect(mod.class.name).to eq 'MiscellaneousResource'
  end

  it 'should find modules by type and id' do
    mod = create :miscellaneous_resource
    expect(@app.find_mod mod.id, 'MiscellaneousResource').to eq mod
  end

  it 'should associate modules with users' do
    mod = create :miscellaneous_resource
    user = create :user
    @app.create_and_add_resource user, mod
    expect(user.resources.length).to eq 1
  end

  it 'should create text slugs' do
    expect(@app.create_slug 'abcdefghijklmnopqrstuvwxyz').to eq 'abcdefghijklmnopqrstuv...'
    expect(@app.create_slug 'abcdefghijklmnopqrstuvwxy').to  eq 'abcdefghijklmnopqrstuvwxy'
  end

  it 'should support local customization' do
    local = Local.create
    expect(@app.local_customization).to eq local
  end

  it 'should list all module types' do
    Local.create
    expect(@app.module_types.map { |m| m[1] }).to match_array \
      %w(database inst lib miscellaneous rss url).map { |s| "#{ s }_resource" }
  end
end
