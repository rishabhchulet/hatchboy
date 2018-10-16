class PublicActivity::Activity
  belongs_to :company
  after_create :email_notification

  private

  def email_notification
    email = Hatchboy::Notifications::Factory.get self
    email.deliver if email.present?
  end
end
