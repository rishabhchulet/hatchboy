require 'spec_helper'

describe Company do

  specify do
    should belong_to(:created_by).class_name('User') 
    should belong_to(:contact_person).class_name('User') 
    should have_many(:users).class_name('User') 
    should have_many(:admins).class_name('User')
    should have_many(:sources).class_name('Source') 
    should have_many(:teams).class_name("Team") 
    should have_many(:payments).class_name("Payment") 

    should validate_presence_of(:name) 
    should validate_presence_of(:created_by) 
    should validate_uniqueness_of(:name).case_insensitive 
  end  

  it "should create company together with customer if all fields are valid" do
    company = described_class.new(name: 'aaa')
    user = (company.users << FactoryGirl.build(:user)).first
    company.created_by = user
    company.should be_valid
    company.save!
    Company.exists?(company).should eq true
    User.exists?(user).should eq true
  end

  context "should not save neither company no customer if one of it has validation errors: " do

    before do
      @company = described_class.new(name: 'aaa')
      @user = (@company.users << FactoryGirl.build(:user)).first
      @company.created_by = @user
      @company.should be_valid
    end

    it "company name not set" do
      @company.name = ''
      @company.should_not be_valid
      Company.exists?(@company).should eq false
      User.exists?(@user).should eq false
    end

    it "company founder not set" do
      @company.created_by = nil
      @company.should_not be_valid
      Company.exists?(@company).should eq false
      User.exists?(@user).should eq false
    end

    it "customer's company not set" do
      @user.company = nil
      @company.should_not be_valid
      Company.exists?(@company).should eq false
      User.exists?(@user).should eq false
    end
  end
end
