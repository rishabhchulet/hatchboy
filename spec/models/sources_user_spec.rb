require 'spec_helper'

describe SourcesUser do
  it { should belong_to :source }
  it { should belong_to :user }

  it {should respond_to :uid }
  it {should respond_to :user }
  it {should respond_to :source }
end
