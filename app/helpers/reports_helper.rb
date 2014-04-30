module ReportsHelper

  def group_timeline_from_params scope, params
    if !params[:date] or params[:date] == "all_time" or (params[:date] == "period" and ((params[:period_to].to_date - params[:period_from].to_date).to_i > 90))
      date_range = (scope.first.g_created_at.to_date.at_beginning_of_month..scope.last.g_created_at.to_date.at_beginning_of_month).select {|d| d.day == 1}
      scope = scope.group_by{|s| s.g_created_at.to_date.at_beginning_of_month}
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
      grouped_data[(date.is_a?(Integer) ? (date_range.count == 1 ? period_scope.first.g_created_at.to_date : Time.at(date).strftime("%I:%M")) : date)] = yield(period_scope, date) || []
    end
    grouped_data
  end

  def retrieve_query_params type, permit_params
    session[:reports] ||= Hash.new
    if params[:set_filter] and params[:type] == type.to_s
      session[:reports][type] = params.select{|p| permit_params.include?(p.to_sym)}
    else
      session[:reports][type] ||= Hash.new
    end
    Hash[session[:reports][type].map{ |k, v| [k.to_sym, v] }]
  end

  def build_chart params
    LazyHighCharts::HighChart.new(params[:data].count > 1 ? 'graph' : 'pie') do |f|
      if params[:data].count > 1 or params[:columns]
        f.title({ :text=> params[:title]})
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
        f.title({ :text=> "#{params[:title]} at #{params[:data].keys.first}"})
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
end