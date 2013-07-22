require 'spec_helper'

describe CommentResource do
  it 'has a valid factory' do
    expect(build :comment_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :comment_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :comment_resource, module_title: 'this is a module'
    expect(mod.label).to eq 'this is a module'
  end

  it 'defaults to 3 comments' do
    mod = create :comment_resource
    expect(mod.num_displayed).to eq 3
  end

  context 'has comments' do
    before :each do
      @mod = create :comment_resource
      @comments = 1.upto(5).map { build :comment }
      @comments.each { |comment| @mod.comments << comment }
    end

    it 'can have many comments' do
      expect(@mod.comments.length).to eq 5
    end

    it 'orders comments most recent first' do
      expect(@mod.ordered_comments).to eq [@comments[4], @comments[3], @comments[2]]
    end

    it 'limits the number of comments shown' do
      @mod.num_displayed = 2
      expect(@mod.ordered_comments).to eq [@comments[4], @comments[3]]
    end

    it 'orders all comments most recent first' do
      expect(@mod.more_comments).to eq @comments.reverse
    end
  end
end
