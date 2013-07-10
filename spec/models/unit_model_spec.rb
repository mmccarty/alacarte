require 'spec_helper'

describe Unit do
  it 'should have a valid factory' do
    expect(build :unit).to be_valid
  end

  it 'should require a title' do
    expect(build :unit, title: nil).to have(1).errors_on :title
  end

  it 'should generate a slug' do
    unit = create :unit, title: 'abcdefghijklmnop'
    expect(unit.slug).to eq 'abcdefghijkl...'
  end
end
