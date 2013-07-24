require 'spec_helper'

describe UploaderResource do
  it 'has a valid factory' do
    expect(build :uploader_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :uploader_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :uploader_resource, module_title: 'this is the title'
    expect(mod.label).to eq mod.module_title
  end
  context 'has uploadables and' do
    before :each do
      @mod = create :uploader_resource
      @uploadables = 1.upto(3).map { build :uploadable }
      @uploadables.each { |u| @mod.uploadables << u }
    end

    it 'can have many uploadables' do
      expect(@mod.uploadables.length ).to eq 3
    end

    it 'will copy uploadables when cloned' do
      copied_mod = @mod.clone
      expect(copied_mod.uploadables).to eq @uploadables
    end

    it 'can build new uploadable attributes' do
      @mod.new_uploadable_attributes= [:upload_link => 'www.boo.com']
      expect(@mod.uploadables.last.upload_link).to eq 'www.boo.com'
    end

    it 'can modify existing uploadable attributes' do
      attrs = @uploadables.map{ |u| [u.id.to_s, {upload_file_name: 'gone', upload_link: u.upload_link }] }
      @mod.existing_uploadable_attributes= Hash[*attrs.flatten]
      expect(@mod.uploadables.map { |u| u.upload_file_name }).to eq ['gone', 'gone', 'gone']
    end

    it 'can save all uploadables' do
      @mod.uploadables.each do |u|
        u.upload_file_name = 'gone'
      end
      @mod.save_uploadables
      expect(@mod.uploadables.map { |u| u.upload_file_name }).to eq ['gone', 'gone', 'gone']
    end
  end
end
