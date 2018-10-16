Dir[File.expand_path("lib/connectors/*_connector.rb")].each {|f| require f}
