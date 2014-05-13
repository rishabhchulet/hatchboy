class Mailer < ActionMailer::Base
  default from: "from@example.com"

  def team_created params
    parse params
    mail to: named_email, subject: 'New team created'
  end

  private

  def named_email
    "#{@recipient.name} <#{@recipient.contact_email}>"
  end

  def parse params
    @recipient = params[:recipient]
    @company = params[:company]
    @object = params[:object]
    @owner = params[:owner]
  end
end
