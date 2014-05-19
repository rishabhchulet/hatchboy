module Hatchboy
  module Notifications
    class DocuTemplates < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'create' then :document_for_signing_was_uploaded
        end
      end

      def recipients
        users = [@object.user] + [@object.docu_signs]
        get_subscribers users
      end

    end
  end
end
