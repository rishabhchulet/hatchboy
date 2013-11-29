require 'spec_helper'

describe Account do
  
  it { should belong_to(:profile) }
  it { should validate_presence_of(:profile) }
  it { should accept_nested_attributes_for(:profile).allow_destroy(true) }

  before(:each) do
    @attr = {
      :email => "user@example.com",
      :password => "changeme",
      :password_confirmation => "changeme",
      :profile_attributes => { 
        :type => "Customer",
        :name => "Example Customer", 
        :company_attributes => {
          :name => "Shakuro"
        } 
      }
    }
  end

  it "should create a new instance given a valid attribute" do
    described_class.create!(@attr)
  end

  it "should require an email address" do
    no_email_user = described_class.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = described_class.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = described_class.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    described_class.create!(@attr)
    user_with_duplicate_email = described_class.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    described_class.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = described_class.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = described_class.new(@attr)
    end

    it "should have a password attribute" do
      @user.should respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "should require a password" do
      described_class.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      described_class.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 4
      hash = @attr.merge(:password => short, :password_confirmation => short)
      described_class.new(hash).should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = described_class.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end

  end
  
  describe "has_role? function" do
    
    before(:each) do
      
      @user = described_class.create!(@attr)
    end
    
    it "should return false for any role but 'customer'" do
      @user.has_role?(:admin).should eq false 
      @user.has_role?(:customer).should eq true
    end
    
  end
  
  describe "profile" do
    
    before do
      @attr.delete(:profile_attributes)
      @user = described_class.new(@attr)
      @profile = @user.profile = FactoryGirl.build(:customer_without_account)
      @company = @profile.company
    end
    
    it "should create account together with profile and company" do
      @user.save
      @user.should be_valid
      @profile.should be_valid
      @company.should be_valid
    end
    
    it "should validate customer name" do
      @profile.company = nil
      @user.should_not be_valid
    end
    
    it "should validate company name" do
      @company.name = ''
      @user.should_not be_valid
    end
    
    it "should create correct company and customer links" do
      @user.save
      @profile.should_not be_new_record
      @company.should_not be_new_record
      @user.should_not be_new_record
      @company.created_by.should eq @profile
      @profile.company.should eq @company
      @company.customers.first.should eq @profile
      @user.profile.should eq @profile
      @profile.account.should eq @user
    end
    
  end

  describe "profile_attributes=" do
    before(:each) do
      @user = described_class.create!(@attr)
    end
    
    it "should be valid" do
      @user.should be_valid
      @user.profile.should be_valid
    end
    
    it "should fill created_by by itself" do
      @user.profile.company.created_by.should eq @user.profile
    end

    it "should fill contact_person by itself" do
      @user.profile.company.contact_person.should eq @user.profile
    end
  end

  describe "build_profile" do
    
    before do
      @user = described_class.new(email: Faker::Internet.email, password: (password = generate(:password)), password_confirmation: password )
    end
    
    it "should profile account with given type" do
      expect { @user.build_profile name: Faker::Name.name, type: 'Customer' }.not_to raise_error
      @user.profile.should be_kind_of Customer
    end
    
    it "should raise error if account type not given" do
      expect { @user.build_account name: Faker::Name.name }.to raise_error
    end
  end

end
