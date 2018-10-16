require 'spec_helper'

describe Post do
  it { should belong_to :user }
  it { should have_many(:teams).through(:post_receivers) }
  it { should have_many(:post_receivers).dependent(:destroy) }
  it { should have_many(:documents).dependent(:destroy) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:message) }

  describe '#documents=' do
    it "creates Document" do
      object = described_class.new
      object.documents = [{:filename => "foobar"}]
      object.documents.first.should be_kind_of(Document)
    end
  end 

end
