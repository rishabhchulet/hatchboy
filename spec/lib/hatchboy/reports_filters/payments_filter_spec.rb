require 'spec_helper'

describe Hatchboy::ReportsFilters::PaymentsFilter do
  let(:payment_filter) { described_class.new }

  context "when filter by params" do

    before do
      create_list :payment_recipient, 2, payment: create(:payment, created_at: (1.month.ago - 1.day)), user: create(:user)
      create :payment_recipient, payment: create(:payment, created_at: (1.week.ago - 1.day))
      create :payment_recipient, payment: create(:payment, created_at: (1.day.ago - 1.hour))
      create :payment_recipient, payment: create(:payment, created_at: 1.hour.ago)
    end

    context "with time params" do

      it "should have payments for all time" do
        payments = payment_filter.filter_by_params({date: "all_time"}).to_a
        payments.count.should eq 4
        payments.group_by(&:g_created_at).count.should eq 2
      end

      it "should have today payments" do
        payments = payment_filter.filter_by_params({date: "today"}).to_a
        payments.count.should eq 1
      end

      it "should have payments in the past week" do
        payments = payment_filter.filter_by_params({date: "last_week"}).to_a
        payments.count.should eq 2
      end

      it "should have payments in the past month" do
        payments = payment_filter.filter_by_params({date: "last_month"}).to_a
        payments.count.should eq 3
      end

      it "should have payments with specific date" do
        payments = payment_filter.filter_by_params({date: "specific", specific_date: Date.today.to_s}).to_a
        payments.count.should eq 1
      end

      it "should have payments in time period" do
        payments = payment_filter.filter_by_params({date: "period", period_from: 1.month.ago.to_s, period_to: Date.today.to_s}).to_a
        payments.count.should eq 3
      end
    end

    it "should be group by users" do
      payments = payment_filter.filter_by_params({group_by: "users"}).to_a
      payments.group_by(&:user_id).count.should eq 4
    end
  end
end