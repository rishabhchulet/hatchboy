module ReportsHelper

  def build_chart_object title, xLabel, data
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => title)
      f.xAxis(:categories => data.map{|e| e[0]})
      f.series(:name => xLabel, :data => data.map{|e| e[1]})
      f.yAxis [
        {:title => {:text => xLabel, :margin => 70}, :min => 0 },
      ]
    end
  end

  def prepare_chart_data_scope data_scope, params
    if params[:date] == "all_time" or (params[:date] == "period" and ((params[:period_to].to_date - params[:period_from].to_date).to_i > 90))
      data_scope = data_scope.with_group_by_mounth.to_a
      date_range = (data_scope.first.created_at.to_date..data_scope.last.created_at.to_date).select {|d| d.day == 1} if data_scope.count > 0
      date_filter = "%Y-%m"
    elsif ["last_week", "last_month", "period"].include? params[:date]
      data_scope = data_scope.with_group_by_day.to_a
      date_range = data_scope.first.created_at.to_date..data_scope.last.created_at.to_date if data_scope.count > 0
      date_filter = "%Y-%m-%d"
    elsif ["today", "specific"].include? params[:date]
      data_scope = data_scope.with_group_by_hours.to_a
      date_range = data_scope.first.created_at.to_time.hour..data_scope.last.created_at.to_time.hour if data_scope.count > 0
    end
    if data_scope.count > 0
      chart_data = date_range.collect do |date|
        val = yield(data_scope, date) || 0
        date_val = date_filter ? date.strftime(date_filter).to_s : date.to_s
        [date_val, val]
      end
    end
    chart_data || []
  end

end