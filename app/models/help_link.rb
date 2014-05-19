class HelpLink < ActiveRecord::Base
  validates :controller, presence: true
  validates :action, presence: true
  validates :link, presence: true, if: "self.video_link.blank?"
  validates :video_link, presence: true, if: "self.link.blank?"
  validates_uniqueness_of :controller, scope: [:action], message: "You can add only one help link on chosen path"
  
  after_validation :set_base_errors

  before_save :parse_video_link

  private

    def set_base_errors
      errors.add(:base, errors[:controller].join(', ')) unless errors[:controller].empty?
    end

    def parse_video_link
      unless self.video_link.blank?
        video_uri = URI(video_link)
        if video_uri.host.include? "youtube.com" and video_uri.query
          video_id = /youtube.com.*(?:\/v\/|v=)([^\/&$]+)/.match(self.video_link)[1]
          self.video_link = "#{video_uri.scheme}://#{video_uri.host}/v/#{video_id}" if video_id
        end
      end
    end
end