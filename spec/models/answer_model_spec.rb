require 'spec_helper'

describe Answer do
  it 'has a valid factory' do
    expect(build :answer).to be_valid
  end
end
