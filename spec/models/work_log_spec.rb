require 'spec_helper'

describe WorkLog do

  it { should belong_to :team }
  it { should belong_to :source }
  it { should belong_to :sources_user }
  it { should belong_to :employee }
  
  it { should validate_presence_of :team }
  
end
