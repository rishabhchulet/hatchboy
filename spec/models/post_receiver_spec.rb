require 'spec_helper'

describe PostReceiver do
  it { should belong_to :post }
  it { should belong_to :receiver }
end
