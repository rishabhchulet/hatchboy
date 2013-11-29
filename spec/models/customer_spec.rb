require "spec_helper"

describe Customer do
  
  it { should belong_to(:company).class_name("Company") }
  it { should have_one(:account).class_name("Account") }
  
  it { should validate_presence_of(:company) }
  
  it "should be possible to create customer without account" do
    customer = described_class.new name: Faker::Name.name
    customer.company = create :company, created_by: customer
    customer.should be_valid
    customer.save
    Customer.exists?(customer).should eq true
    Company.exists?(customer.company).should eq true
  end
  
end
