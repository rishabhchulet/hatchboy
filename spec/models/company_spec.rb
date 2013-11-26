require 'spec_helper'

describe Company do
  it { should belong_to(:created_by).class_name('User') }
  it { should belong_to(:contact_person).class_name('User') }
  it { should validate_presence_of(:name) }
end
