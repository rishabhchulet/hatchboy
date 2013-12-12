require 'spec_helper'
require 'carrierwave/test/matchers'

describe AvatarUploader do
  include CarrierWave::Test::Matchers

  before do
    AvatarUploader.enable_processing = true
    @uploader = AvatarUploader.new(@user, :avatar)
    @uploader.store!(File.open(Rails.root.to_s + "/spec/fixtures/images/test.png"))
  end

  after do
    AvatarUploader.enable_processing = false
    @uploader.remove!
  end

  context 'original version' do
    it "should scale down a landscape image to be exactly 200 by 200 pixels" do
      @uploader.should be_no_larger_than(200, 200)
    end
  end

  context 'the thumb version' do
    it "should scale down a landscape image to fit within 50 by 50 pixels" do
      @uploader.thumb.should have_dimensions(50, 50)
    end
  end

  it "should make the image readable only to the owner and not executable" do
    @uploader.should have_permissions(0600)
  end
end
