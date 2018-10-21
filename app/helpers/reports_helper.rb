module ReportsHelper

  def group_timeline_from_params scope, params
    if ["last_week", "last_month"].include?(params[:date]) or (params[:date] == "period" and ((parse_date(params[:period_to]) - parse_date(params[:period_from])).to_i < 31))
      date_range = scope.first.g_created_at.to_date..scope.last.g_created_at.to_date
      scope = scope.group_by{|s| s.g_created_at.to_date}
    elsif ["today", "specific"].include? params[:date]
      date_range = (scope.first.g_created_at.to_i..scope.last.g_created_at.to_i).step(1.hour)
      scope = scope.group_by{|s| s.g_created_at.to_time}
    else
      date_range = (scope.first.g_created_at.to_date.at_beginning_of_month..scope.last.g_created_at.to_date.at_beginning_of_month).select {|d| d.day == 1}
      scope = scope.group_by{|s| s.g_created_at.to_date.at_beginning_of_month}
      date_mask = "%B %Y"
    end
    grouped_data = date_range.map do |date|
      period_scope = date.is_a?(Integer) ? scope[Time.at(date)] : scope[date]
      if date.is_a?(Integer)
        formated_date = date_range.count == 1 ? period_scope.first.g_created_at.strftime("%d %B %Y") : Time.at(date).strftime("%I:%M")
      else
        formated_date = date.strftime((date_mask or "%d %B %Y"))
      end
      [formated_date, yield(period_scope, date)]
    end
    Hash[grouped_data]
  end

  def retrieve_query_params type, permit_params
    session[:reports] ||= Hash.new
    if params[:set_filter] and (params[:type] == type.to_s or params[:type] == "all")
      session[:reports][type] = params.select{|p| permit_params.include?(p.to_sym)}
    else
      session[:reports][type] ||= Hash.new
    end
    Hash[session[:reports][type].map{ |k, v| [k.to_sym, v] }]
  end

  def build_chart params
    LazyHighCharts::HighChart.new(params[:data].count > 1 ? 'graph' : 'pie') do |f|
      f.title({ :text=> params[:title]})
      if params[:data].count > 1 or params[:columns]
        f.options[:xAxis][:categories] = params[:data].keys
        f.options[:chart][:zoomType] = 'x,y'
        params[:data].values.flatten.group_by{|i| i[:id]}.each do |id, item|
          f.series(:type=> 'column',:name=> item.first[:name], :data=> item.map{|d| d[:value]}, maxPointWidth: 100)
        end
        unless params[:without_average]
          f.series(:type=> 'spline',:name=> 'Average', :data=> params[:data].values.collect{|a| a.map{|i| i[:value]}.instance_eval { (reduce(:+) / size.to_f).round(2) } })
        end
        f.yAxis [
          {:title => {:text => params[:y_title], :margin => 10}, :min => 0},
        ]
        f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
      else
        f.labels(:items=>[:html=> params[:data].keys.first, :style=>{:left=>"300px", :top=>"300px", :color=>"black"} ]) 
        f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 200, 60, 170]} )
        f.series(:type=> 'pie',:name => params[:y_title], :data => params[:data].values.first.map{|v| [v[:name], v[:value]]}, :innerSize => (params[:innerSize] ? params[:innerSize] : "0%"))
        f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'})
        f.plot_options(:pie=> { :allowPointSelect=>true, :cursor=>"pointer", :dataLabels=> { :enabled=>true, :color=>"black" } } )
      end
    end
  end

  def parse_date date
    DateTime.parse(date) rescue Date.today
  end

  def build_report type
    report = case type
      when :hours then Hatchboy::Reports::Builders::HoursBuilder.new(retrieve_query_params(:hours, Hatchboy::Reports::Builders::HoursBuilder::AVAILABLE_PARAMS))
      when :payments then Hatchboy::Reports::Builders::PaymentsBuilder.new(retrieve_query_params(:payments, Hatchboy::Reports::Builders::PaymentsBuilder::AVAILABLE_PARAMS))
      when :mvp then Hatchboy::Reports::Builders::MvpBuilder.new(retrieve_query_params(:mvp, Hatchboy::Reports::Builders::MvpBuilder::AVAILABLE_PARAMS))
      when :ratings then Hatchboy::Reports::Builders::RatingsBuilder.new({})
    end
    report.set_company(account_company).build_report_data({chart: true}) if report
    report
  end

  def report_title_from_params params
    case params[:date]
      when "last_month" then "the last month"
      when "last_week" then "the last week"
      when "specific" then parse_date(params[:specific_date]).strftime("%d.%m.%Y")
      when "period" then "#{parse_date(params[:period_from]).strftime("%d.%m.%Y")} - #{parse_date(params[:period_to]).strftime("%d.%m.%Y")}"
      when "today" then "today"
      else "all time"
    end
  end
end