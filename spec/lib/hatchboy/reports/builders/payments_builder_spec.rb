require 'spec_helper'

describe Hatchboy::Reports::Builders::PaymentsBuilder do
  let(:payments_builder) { described_class.new({}) }

  subject { payments_builder }
  
  it {should respond_to :users }
  it {should respond_to :users_payments }
  it {should respond_to :chart }
  it {should respond_to :params }
end