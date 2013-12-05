require "spec_helper"

describe Customer do
  
  it { should belong_to(:company).class_name("Company") }
  it { should have_one(:account).class_name("Account") }
  it { should accept_nested_attributes_for(:company).allow_destroy(true) }  
  it { should accept_nested_attributes_for(:account).allow_destroy(true) }
  
  it { should validate_presence_of(:company) }
  
  it "should be possible to create customer without account" do
    customer = described_class.new name: Faker::Name.name
    customer.company = create :company, created_by: customer
    customer.should be_valid
    customer.save
    Customer.exists?(customer).should eq true
    Company.exists?(customer.company).should eq true
  end
  
  it "should create company from company_attributes" do
    @attr = { name: Faker::Name.name, company_attributes: { name: Faker::Company.name }}
    customer = described_class.create(@attr)
    customer.should be_valid
    customer.name.should eq @attr[:name]
    customer.company.name.should eq @attr[:company_attributes][:name]
  end
  
end
