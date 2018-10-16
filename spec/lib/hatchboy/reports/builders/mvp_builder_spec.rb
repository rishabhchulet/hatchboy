require 'spec_helper'

describe Hatchboy::Reports::Builders::MvpBuilder do
  let(:mvp_builder) { described_class.new({}) }

  subject { mvp_builder }
  
  it {should respond_to :users }
  it {should respond_to :scores }
  it {should respond_to :chart }
  it {should respond_to :params }
end