class NotificationsMailer < ActionMailer::Base
  
  default from: "from@example.com"

  Subscription::SUBSCRIPTION_COLUMNS.each do |notification|
    define_method(notification) { |params|
      @recipient = params[:recipient]
      @company = params[:company]
      @object = params[:object]
      @owner = params[:owner]
      @owner_url = user_url @owner
 
      mail to: recipient_email
    }
  end

  private

  def recipient_email
    "#{@recipient.name} <#{@recipient.contact_email}>"
  end
end
