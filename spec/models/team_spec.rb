require 'spec_helper'

describe Team do
  
  it {should belong_to :company }
  it {should belong_to :created_by }
  it {should have_many :worklogs } 
  
end
