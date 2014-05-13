module Hatchboy
  module Notifications
    class Factory

      def initialize activity
        @activity = activity
        @company = activity.company
        @object = activity.trackable_type.constantize.where(id: activity.trackable_id).first
        @owner = activity.owner_type.constantize.where(id: activity.owner_id).first if activity.owner_type
      end

      def deliver
        recipients.each do |recipient|
          mail = ::Mailer.public_send(@action, {
            recipient: recipient,
            company: @company,
            object: @object,
            owner: @owner
          })
          mail.deliver
        end
      end

      def self.get activity
        model_name, action = activity.key.split '.'
        service = "Hatchboy::Notifications::#{model_name.camelize}".constantize
        service.new action, activity
      rescue NameError
        nil
      end

    end
  end
end
