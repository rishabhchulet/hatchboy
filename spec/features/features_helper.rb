Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Capybara.app = Rails.application
Capybara.default_driver    = :poltergeist_debug
Capybara.javascript_driver = :poltergeist_debug
Capybara.default_selector  = :css

Capybara.add_selector(:flash) do
  css { |type| ".alert.alert-#{type}" }
end

module FeaturesHelper

  def sign_in! account
    session = Capybara::Session.new Capybara.current_driver, Capybara.app
    session.visit new_account_session_path
    session.within("form") do
      session.fill_in "Email", with: account.email
      session.fill_in "Password", with: account.password
    end
    session.click_button "Sign in"
    session
  end
  
  def use_selenium
    Capybara.current_driver = :selenium
  end
  
  def screenshot session = nil
    file = "page_#{rand(1000..9999)}.png"
    source = session || page
    source.save_screenshot Rails.root.to_s + "/tmp/" + file
  end  
  
end
