require 'spec_helper'

describe Uploadable do

  it 'has a valid factory' do
    expect(build :uploadable).to be_valid
  end

  it 'belongs to an uploader resource' do
    uploader = create :uploader_resource
    uploadable = build :uploadable
    uploader.uploadables << uploadable
    expect(uploadable.uploader_resource).to eq uploader
  end

  context 'can generate logos' do
    before :each do
      @uploader = build :uploadable
    end

    it 'can generate logos for a pdf' do
      @uploader.upload_content_type = 'application/pdf'
      image, title, link = @uploader.logo
      expect(image).to eq 'icons/pdf.png'
    end

    it 'can generate logos for a powerpoint' do
      @uploader.upload_content_type = 'application/vnd.ms-powerpoint'
      image, title, link = @uploader.logo
      expect(image).to eq 'icons/ppt.png'
    end

    it 'can generate logos for an image' do
      @uploader.upload_content_type = 'image/jpg'
      image, title, link = @uploader.logo
      expect(image).to eq 'icons/image.png'
    end

    it 'can generate default logo' do
      image, title, link = @uploader.logo
      expect(image).to eq 'icons/word.png'
    end
  end

end
