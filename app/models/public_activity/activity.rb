class PublicActivity::Activity
  after_create :email_notification

  private

  def email_notification
    notification = Hatchboy::Notifications::Factory.get self
    notification.send
  end
end
