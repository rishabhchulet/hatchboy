module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
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
  
end
