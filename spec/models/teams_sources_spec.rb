require 'spec_helper'

describe TeamsSources do
  it { should belong_to :team }
  it { should belong_to :source }
end
