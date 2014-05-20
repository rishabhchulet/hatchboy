module Hatchboy
  module Notifications
    class DocuSigns < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'update' then :document_was_signed
        end
      end

      def recipients
        users = [@object.user] + [@object.docu_template.user] + @company.admins
        get_subscribed users
      end

    end
  end
end
