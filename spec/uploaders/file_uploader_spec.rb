require 'spec_helper'
require 'carrierwave/test/matchers'

describe FileUploader do
  include CarrierWave::Test::Matchers

  before do
    described_class.enable_processing = true
    @document = create(:document)
    @uploader = described_class.new(@document, :doc_file)
    @file = File.open(Rails.root.to_s + "/spec/fixtures/images/test.png")
    @uploader.store!( @file )
  end

  after do
    described_class.enable_processing = false
    @uploader.remove!
  end
    
  specify do
    debugger
    @document.doc_type.should eq "image/png"
    @document.doc_size.should eq @file.size
  end

end
