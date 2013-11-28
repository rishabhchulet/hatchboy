require 'spec_helper'

describe Company do
  
  it { should belong_to(:created_by).class_name('User') }
  it { should belong_to(:contact_person).class_name('User') }
  it { should have_many(:customers).class_name('User') }
  
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:created_by) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  
  it "should create company together with customer if all fields are valid" do
    company = described_class.new(name: 'aaa')
    customer = company.customers.build( name: 'asd', email: '123@asd.com', password: 'future', password_confirmation: 'future', company: company )
    company.created_by = customer
    company.should be_valid
    company.save!
    Company.exists?(company).should eq true
    User.exists?(customer).should eq true
  end
  
  context "should not save neither company no customer if one of it has validation errors: " do
    
    it "password not match confirmation" do
      company = described_class.new(name: 'aaa')
      customer = company.customers.build( name: 'asd', email: '123@asd.com', password: 'future', password_confirmation: 'futur', company: company )
      company.created_by = customer
      company.should_not be_valid
      Company.exists?(company).should eq false
      User.exists?(customer).should eq false
    end
    
    it "company name not set" do
      company = described_class.new
      customer = company.customers.build( name: 'asd', email: '123@asd.com', password: 'future', password_confirmation: 'future', company: company )
      company.created_by = customer
      company.should_not be_valid
      Company.exists?(company).should eq false
      User.exists?(customer).should eq false
    end

    it "company founder not set" do
      company = described_class.new(name: "aaa")
      customer = company.customers.build( name: 'asd', email: '123@asd.com', password: 'future', password_confirmation: 'future', company: company )
      company.should_not be_valid
      Company.exists?(company).should eq false
      User.exists?(customer).should eq false
    end

    it "customer's company not set" do
      company = described_class.new(name: "aaa")
      customer = company.customers.build( name: 'asd', email: '123@asd.com', password: 'future', password_confirmation: 'future')
      company.created_by = customer
      company.should_not be_valid
      Company.exists?(company).should eq false
      User.exists?(customer).should eq false
    end
  end
end
