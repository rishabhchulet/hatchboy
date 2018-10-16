require 'spec_helper'

describe WorkLog do

  it { should belong_to :team }
  it { should belong_to :source }
  it { should belong_to :user }

  it { should validate_presence_of :team }
  it { should validate_presence_of :time }
  it { should validate_presence_of :user }
end

