require 'spec_helper'

describe HelpLink do

  context "Class object" do
    specify do
      should be_kind_of HelpLink
      should respond_to :controller
      should respond_to :action
      should respond_to :link
      should respond_to :video_link
      should respond_to :created_at
      should respond_to :updated_at
    end
  end

  context "while validation" do

    let(:help_link) { build :help_link }
    subject { help_link }

    it { should be_valid }
    it { should validate_presence_of :controller}
    it { should validate_presence_of :action}

    context "when link or video link is empty" do

      context "when link is empty" do
        before { help_link.link = "" }
        it { should be_valid }
      end

      context "when video link is empty" do
        before { help_link.video_link = "" }
        it { should be_valid }
      end
    end

    context "when link and video link is empty" do
      before { help_link.link = help_link.video_link = "" }
      it { should_not be_valid }
    end

    context "when dublicate with same controller and action" do
      before do
        new_help_link = help_link.dup
        new_help_link.save!
      end
      it { should_not be_valid }
    end
  end
end