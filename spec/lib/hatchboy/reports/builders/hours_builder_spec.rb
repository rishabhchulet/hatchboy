require 'spec_helper'

describe Hatchboy::Reports::Builders::HoursBuilder do
  let(:hours_builder) { described_class.new({}) }

  subject { hours_builder }

  it {should respond_to :users }
  it {should respond_to :teams }
  it {should respond_to :teams_users }
  it {should respond_to :users_worklogs }
  it {should respond_to :chart }
  it {should respond_to :params }
end