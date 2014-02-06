require 'spec_helper'

describe User do

  it { should belong_to :company }
  it { should have_many :teams }

  it { should validate_presence_of :name}

  it { should validate_presence_of :company}

  it { should have_one(:account).class_name("Account")
  }
  it { should accept_nested_attributes_for(:company).allow_destroy(true) }
  it { should accept_nested_attributes_for(:account).allow_destroy(true) }

  it { should validate_presence_of(:company) }
  it { should validate_presence_of(:name) }

  it "should be possible to create user without account" do
    user = described_class.new name: Faker::Name.name
    user.company = create :company, created_by: user
    user.should be_valid
    user.save
    User.exists?(user).should eq true
    Company.exists?(user.company).should eq true
  end

  it "should create company from company_attributes" do
    @attr = { name: Faker::Name.name, company_attributes: { name: Faker::Company.name }}
    user = described_class.create(@attr)
    user.should be_valid
    user.name.should eq @attr[:name]
    user.company.name.should eq @attr[:company_attributes][:name]
  end

  it "should validate email format" do
    user = described_class.create(name: "foo", company: create(:company))
    user.should be_valid
    user.contact_email = "wrond@email"
    user.should_not be_valid
    user.contact_email = "valid@email.com"
    user.should be_valid
  end

end
