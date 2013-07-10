require 'spec_helper'

describe Resource do
  it 'should be findable my module id and type' do
    mod = create :miscellaneous_resource
    res = Resource.create mod: mod
    expect(Resource.find_by_mod_id_and_mod_type mod.id, mod.class.name).to eq res
  end

  it 'should be findable my module type and id' do
    mod = create :miscellaneous_resource
    res = Resource.create mod: mod
    expect(Resource.where(mod_type: mod.class.name, mod_id: mod.id).first).to eq res
  end

  it 'should by default not be shared' do
    mod = create :miscellaneous_resource
    res = Resource.create mod: mod
    expect(res).to_not be_shared
  end

  it 'should be able to be shared' do
    mod = create :miscellaneous_resource
    res = Resource.create mod: mod
    2.times { user = create :user; user.add_resource res }
    expect(res).to be_shared
  end
end
