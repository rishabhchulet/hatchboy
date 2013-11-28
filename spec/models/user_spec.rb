require 'spec_helper'

describe User do
  
  it { should belong_to(:company) }
  it { should validate_presence_of(:company) }
  it { should accept_nested_attributes_for(:company).allow_destroy(true) }

  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "changeme",
      :password_confirmation => "changeme",
      :company_attributes => { :name => "Foobar" }
    }
  end

  it "should create a new instance given a valid attribute" do
    User.create!(@attr)
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = User.new(@attr)
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
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 4
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
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
      @user = User.create!(@attr)
    end
    
    it "should return false for any role but 'customer'" do
      @user.has_role?(:admin).should eq false 
      @user.has_role?(:customer).should eq true
    end
    
  end
  
  describe "company" do
    
    before do
      @user = described_class.new(name: Faker::Name.name, email: Faker::Internet.email, password: password = FactoryGirl.generate(:password), password_confirmation: password)
      @company = @user.build_company(name: Faker::Company.name, created_by: @user)
    end
    
    it "should create user together with company" do
      @user.save
      @user.should be_valid
      @company.should be_valid
    end
    
    it "should validate company name" do
      @company.name = ''
      @user.should_not be_valid
    end
    
    it "should create correct company and customer links" do
      @user.save
      @company.should_not be_new_record
      @user.should_not be_new_record
      @company.created_by.should eq @user
      @user.company.should eq @company
      @company.customers.first.should eq @user
    end
    
    it "should create another customer in the company" do
      @user.save
      @another_user = described_class.new(
        name: Faker::Name.name, email: Faker::Internet.email, password: password = FactoryGirl.generate(:password),
        password_confirmation: password, company: @company
      )
      @another_user.should be_valid
      @another_user.save
      @another_user.company.should eq @user.company
      @company.reload.customers.count.should eq 2
      @company.customers.should include @user
      @company.customers.should include @another_user
    end
    
  end

  describe "company_attributes=" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should be valid" do
      @user.should be_valid
      @user.company.should be_valid
    end
    
    it "should set right company" do
      @user.company.created_by.should eq @user
    end
    
    it "should fill created_by by itself" do
      @user.company.created_by.should eq @user
    end

    it "should fill contact_person by itself" do
      @user.company.contact_person.should eq @user
    end
  end

end
