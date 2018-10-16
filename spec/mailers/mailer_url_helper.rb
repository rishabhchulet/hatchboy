class  ActionDispatch::Routing::RouteSet
   def default_url_options(options = {})
     {
       host: 'localhost',
     }.merge(options)
   end
end
RSpec.configure do |config|
  config.include(Rails.application.routes.url_helpers)
end