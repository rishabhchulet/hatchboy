require 'spec_helper'

describe SourcesUser do
  it { should belong_to :employee }
  it { should belong_to :source }
  
  it {should respond_to :name }
  it {should respond_to :email }
end
