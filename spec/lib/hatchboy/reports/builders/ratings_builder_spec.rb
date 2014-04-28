require 'spec_helper'

describe Hatchboy::Reports::Builders::RatingsBuilder do
  let(:ratings_builder) { described_class.new({}) }

  subject { ratings_builder }
  
  it {should respond_to :users }
  it {should respond_to :chart }
  it {should respond_to :params }
end