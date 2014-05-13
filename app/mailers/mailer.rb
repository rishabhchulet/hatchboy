class Mailer < ActionMailer::Base
  
  default from: "from@example.com"

  notifications = [
    'team_created',
    'team_deleted',
    'user_created',
    'user_deleted'
  ]

  notifications.each do |notification|
    define_method(notification) { |params|
      @recipient = params[:recipient]
      @company = params[:company]
      @object = params[:object]
      @owner = params[:owner]
 
      mail to: named_email, subject: I18n.t("email.#{notification}.subject")
    }
  end

  private

  def named_email
    "#{@recipient.name} <#{@recipient.contact_email}>"
  end
end
