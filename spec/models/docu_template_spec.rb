require 'spec_helper'

describe DocuTemplate do
  it { should belong_to :company }

  describe "#users" do
    before do
      user = create(:user)

      stub_request(:post, "https://demo.docusign.net/restapi/v2/accounts/446141/envelopes").
      to_return(:status => 200, :body => {"envelopeId"=>"ab55e07e-50d2-4263-9508-1857a4037881", "uri"=>"/envelopes/ab55e07e-50d2-4263-9508-1857a4037881", "statusDateTime"=>"2014-03-18T09:42:38.0251145Z", "status"=>"sent"}.to_json, :headers => {})
# "{\"templateId\"=>\"2efb3dda-df86-4745-92a7-5797ecaf430f\", \"name\"=>\"Template Name empty signer\", \"uri\"=>\"/templates/2efb3dda-df86-4745-92a7-5797ecaf430f\"}"
# "{\"envelopeId\"=>\"ab55e07e-50d2-4263-9508-1857a4037881\", \"uri\"=>\"/envelopes/ab55e07e-50d2-4263-9508-1857a4037881\", \"statusDateTime\"=>\"2014-03-18T09:42:38.0251145Z\", \"status\"=>\"sent\"}"
      @template = DocuTemplate.new( { :document => Rack::Test::UploadedFile.new( Rails.root.join("pdfSample.pdf"), "application/pdf"), 
                                            :users => "user_#{user.id}"} )
    end

    it "creates docusign object" do
      @template.docu_signs.first.envelope_id.should eq "ab55e07e-50d2-4263-9508-1857a4037881"
    end

  end
end
