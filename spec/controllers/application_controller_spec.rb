require 'spec_helper'

describe ApplicationController do
  before(:each) { @app = ApplicationController.new }

  it 'should associate modules with users' do
    mod = create :node
    user = create :user
    @app.create_and_add_node user, mod
    expect(user.nodes.length).to eq 1
  end

  it 'should create text slugs' do
    expect(@app.create_slug 'abcdefghijklmnopqrstuvwxyz').to eq 'abcdefghijklmnopqrstuv...'
    expect(@app.create_slug 'abcdefghijklmnopqrstuvwxy').to  eq 'abcdefghijklmnopqrstuvwxy'
  end

  it 'should support local customization' do
    local = Local.create
    expect(@app.local_customization).to eq local
  end
end
