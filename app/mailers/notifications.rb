class Notification < ActionMailer::Base
  default from: "from@example.com"

  def teams_users_created recipient, params
    @recipient = recipient
    @company = params[:company]
    @team = params[:team]
    @user = params[:user]

    mail to: "#{@user.name} <#{@user.email}>", 
        subject: 'User was added to team'

  end
end
