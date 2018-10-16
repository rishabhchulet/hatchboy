CarrierWave.configure do |config|
  config.permissions = 0600
  config.directory_permissions = 0777
  config.storage = :file
  config.enable_processing = false if Rails.env.test? 
end
