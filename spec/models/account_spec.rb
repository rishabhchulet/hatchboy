require 'spec_helper'

describe Account do

  it { should belong_to(:user) }
  it { should validate_presence_of(:user) }
  it { should accept_nested_attributes_for(:user).allow_destroy(true) }

  before(:each) do
    @attr = {
      :email => "user@example.com",
      :password => "changeme",
      :password_confirmation => "changeme",
      :user_attributes => {
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
      @account = described_class.create!(@attr)
    end

    it "should return false for any role but 'customer'" do
      @account.has_role?(:admin).should eq false
      @account.has_role?(:customer).should eq true
    end

  end

  describe "user" do

    before do
      @attr.delete(:user_attributes)
      @account = described_class.new(@attr)
      @user = @account.user = FactoryGirl.build(:user_without_account)
      @company = @user.company
    end

    it "should create account together with user and company" do
      @account.save
      @account.should be_valid
      @user.should be_valid
      @company.should be_valid
    end

    it "should validate customer name" do
      @user.company = nil
      @account.should_not be_valid
    end

    it "should validate company name" do
      @company.name = ''
      @account.should_not be_valid
    end

    it "should create correct company and customer links" do
      @account.save
      @user.should_not be_new_record
      @company.should_not be_new_record
      @account.should_not be_new_record
      @company.created_by.should eq @user
      @user.company.should eq @company
      @company.users.first.should eq @user
      @account.user.should eq @user
      @user.account.should eq @account
    end

  end

  describe "user_attributes=" do
    before(:each) do
      @account = described_class.create!(@attr)
    end

    it "should be valid" do
      @account.should be_valid
      @account.user.should be_valid
    end

    it "should fill created_by by itself" do
      @account.user.company.created_by.should eq @account.user
    end

    it "should fill contact_person by itself" do
      @account.user.company.contact_person.should eq @account.user
    end
  end

  describe "build_user" do

    before do
      @account = described_class.new(email: Faker::Internet.email, password: (password = generate(:password)), password_confirmation: password )
    end

    it "should user account with given type" do
      expect { @account.build_user name: Faker::Name.name}.not_to raise_error
      @account.user.should be_kind_of User
    end

  end

  context "while update user" do

    before do
      @account = create :account
      @attr = { user_attributes: { name: Faker::Name.name}, email: Faker::Internet.email, password: "new_password", password_confirmation: "new_password" }
    end

    it "should save attributes" do
      @account.update_attributes(@attr).should eq true
      @account.should be_valid
      @account.reload.valid_password?("new_password").should eq true
      @account.user.reload.name.should eq @attr[:user_attributes][:name]
      @account.unconfirmed_email.should eq @attr[:email]
    end

    it "should validate password and confirmation" do
      @attr[:password_confirmation] = ''
      @account.update_attributes(@attr).should eq false
      @account.should_not be_valid
    end

    it "should validate email" do
      @attr[:email] = 'invalid@email'
      @account.update_attributes(@attr).should eq false
      @account.should_not be_valid
    end

  end

end

