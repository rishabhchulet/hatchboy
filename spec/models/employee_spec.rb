require 'spec_helper'

describe Employee do
  
  it { should belong_to :company }
  
end
