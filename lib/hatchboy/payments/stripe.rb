module Hatchboy
  module Payments
    class Stripe

      attr_reader :api, :last_response

      def initialize params
        ::Stripe.api_key = params[:secret_key]
      end

      def valid?
        balance
        return true
      rescue ::Stripe::AuthenticationError, ::Stripe::APIConnectionError => e
        return false
      end

      def balance
        balance = ::Stripe::Balance.retrieve()
        balance.available.first.amount.to_f
      end

      def get_event event_id
         ::Stripe::Event.retrieve(event_id)
      rescue ::Stripe::StripeError
        return false
      end

      def pay payment
        if (with_no_stripe = payment.recipients.select{|r| r.user.stripe_recipient.nil?}).any?
          raise "Recipients #{with_no_stripe.map{|r| r.user.name}.join(', ')} did not set stripe data"
        end
        raise "Your current balance less than payment amount" if Rails.env.production? and balance < payment.amount

        info = payment.recipients.map do |r|
          begin
            transfer = ::Stripe::Transfer.create(
              :amount => (r.amount*100).to_i,
              :currency => "usd",
              :recipient => r.user.stripe_recipient.recipient_token
            )

            r.update_attribute(:stripe_transfer_id, transfer.id)
            {success: true, recipient_id: r.id, transfer: transfer}
          rescue ::Stripe::StripeError => e
            {success: false, recipient_id: r.id, message: e.message}
          end
        end

        return {success: true, additional_info: info}
      rescue StandardError => e
        return {success: false, message: e.message}
      end

      def save_recipient recipient
        if recipient.recipient_token.present?
          update_recipient recipient
        else
          create_recipient recipient
        end
      end

      private 

        def create_recipient recipient
          stripe_recipient = ::Stripe::Recipient.create(
            :name => recipient.full_name,
            :email => recipient.user.contact_email,
            :description => "#{recipient.user.name}: #{recipient.user.contact_email}",
            :card => recipient.stripe_token,
            :type => "individual"
          )

          {recipient_token: stripe_recipient.id, last_4_digits: stripe_recipient.cards.first.last4}
        rescue ::Stripe::StripeError => e
          recipient.errors.add :base, e.message
          return false
        end

        def update_recipient recipient
          stripe_recipient = ::Stripe::Recipient.retrieve(recipient.recipient_token)
          stripe_recipient.card = recipient.stripe_token if recipient.stripe_token.present?
          stripe_recipient.email = recipient.user.contact_email
          stripe_recipient.description = "#{recipient.user.name}: #{recipient.user.contact_email}"
          stripe_recipient.save

          {recipient_token: stripe_recipient.id, last_4_digits: stripe_recipient.cards.first.last4}
        rescue ::Stripe::InvalidRequestError => e
          create_recipient recipient
        rescue ::Stripe::StripeError => e
          recipient.errors.add :base, e.message
          return false
        end

    end
  end
end
