class HelpLink < ActiveRecord::Base
  validates :controller, presence: true
  validates :action, presence: true
  validates :link, presence: true, if: "self.video_link.blank?"
  validates :video_link, presence: true, if: "self.link.blank?"
  validates_uniqueness_of :controller, scope: [:action], message: "You can add only one help link on chosen path"
  after_validation :set_base_errors

  private

    def set_base_errors
      errors.add(:base, errors[:controller].join(', ')) unless errors[:controller].empty?
    end
end