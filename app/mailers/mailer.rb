class Mailer < ActionMailer::Base
  
  default from: "from@example.com"

  notifications = [
    :user_was_added,
    :user_was_removed,
    :team_was_added,
    :team_was_removed,
    :payment_was_sent,
    :data_source_was_created,
    :document_for_signing_was_uploaded,
    :data_source_added_to_team,
    :post_added_to_team,
    :user_added_to_team,
    :time_log_added_to_team
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
