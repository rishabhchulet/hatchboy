module ReportsHelper

  def group_timeline_from_params scope, params
    if params[:date] == "all_time" or (params[:date] == "period" and ((params[:period_to].to_date - params[:period_from].to_date).to_i > 90))
      date_range = (scope.first.g_created_at.to_date..scope.last.g_created_at.to_date).select {|d| d.day == 1}
      scope = scope.group_by{|s| s.g_created_at.to_date}
    elsif ["last_week", "last_month", "period"].include? params[:date]
      date_range = scope.first.g_created_at.to_date..scope.last.g_created_at.to_date
      scope = scope.group_by{|s| s.g_created_at.to_date}
    elsif ["today", "specific"].include? params[:date]
      date_range = (scope.first.g_created_at.to_i..scope.last.g_created_at.to_i).step(1.hour)
      scope = scope.group_by{|s| s.g_created_at.to_time}
    end
    grouped_data = {}
    date_range.each do |date|
      period_scope = (date.is_a? Integer) ? scope[Time.at(date)] : scope[date]
      grouped_data[(date.is_a?(Integer) ? Time.at(date).strftime("%I:%M") : date)] = yield(period_scope, date) || []
    end
    grouped_data
  end
end