require 'spec_helper'

describe Hatchboy::Reports::Filters::WorkLogsFilter do
  let(:worklog_filter) { described_class.new }

  context "when filter by params" do

    before do
      create_list :work_log, 2, on_date: (1.month.ago - 1.day), user: create(:user)
      create_list :work_log, 2, on_date: (1.week.ago - 1.day), team: create(:team)
      create :work_log, on_date: (1.day.ago - 1.hour)
      create :work_log, on_date: 1.hour.ago
    end

    context "with time params" do

      it "should have worklogs for all time" do
        worklogs = worklog_filter.filter_by_params({date: "all_time"}).to_a
        worklogs.count.should eq 5
        worklogs.group_by(&:g_created_at).count.should eq 2
      end

      it "should have today worklogs" do
        worklogs = worklog_filter.filter_by_params({date: "today"}).to_a
        worklogs.count.should eq 1
      end

      it "should have worklogs in the past week" do
        worklogs = worklog_filter.filter_by_params({date: "last_week"}).to_a
        worklogs.count.should eq 2
      end

      it "should have worklogs in the past month" do
        worklogs = worklog_filter.filter_by_params({date: "last_month"}).to_a
        worklogs.count.should eq 4
      end

      it "should have worklogs with specific date" do
        worklogs = worklog_filter.filter_by_params({date: "specific", specific_date: Date.today.to_s}).to_a
        worklogs.count.should eq 1
      end

      it "should have worklogs in time period" do
        worklogs = worklog_filter.filter_by_params({date: "period", period_from: 1.month.ago.to_s, period_to: Date.today.to_s}).to_a
        worklogs.count.should eq 4
      end
    end

    context "with group params" do

      it "should be group by users" do
        worklogs = worklog_filter.filter_by_params({group_by: "users"}).to_a
        worklogs.group_by(&:user_id).count.should eq 5
      end

      it "should be group by teams" do
        worklogs = worklog_filter.filter_by_params({group_by: "teams"}).to_a
        worklogs.group_by(&:team_id).count.should eq 5
      end
    end
  end
end