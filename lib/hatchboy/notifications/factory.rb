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
        Array.wrap(recipients).each do |recipient|
          mail = ::Mailer.public_send(@subscription_name, {
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
        service = "Hatchboy::Notifications::#{model_name.camelize.pluralize}".constantize
        service.new action, activity
      rescue NameError
        nil
      end

      private

      def admin_recipients
        @company.admins.with_account.joins(:subscription)
          .where(subscriptions: {@subscription_name => true}) if @company
      end

    end
  end
end
