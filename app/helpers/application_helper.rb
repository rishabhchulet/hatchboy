module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-danger">
      <button class="close" aria-hidden="true" data-dismiss="alert" type="button"></button>
      <div id="flash_error}">#{msg}</div>
    </div>
    HTML
    html.html_safe
  end

  def display_flash_message type, message
    return "" unless message.is_a?(String)
    html = <<-HTML
    <div class="alert alert-#{type == :notice ? "success" : "danger"}">
      <button class="close" aria-hidden="true" data-dismiss="alert" type="button"></button>
      <div id="flash_#{type}">#{message}</div>
    </div>
    HTML
    html.html_safe
  end

  def title page_title
    content_for :title, page_title.to_s
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def val_in_percent value, max_value
    100 - ((max_value - value.to_f)/max_value * 100)
  end

  def nice_time_difference delta

    return "0h" if delta.to_f == 0

    map = {days: 'd', hours: 'h', minutes: 'm', seconds: 's'}

    components = map.keys.collect do |step|
      seconds = 1.send(step) / 3600.0
      [map[step], (delta / seconds).to_i].tap do
        delta %= seconds
      end
    end

    components.reduce("") {|res, m| m[1] == 0 ? res : res + "#{m[1]}#{m[0]} "}
  end

end