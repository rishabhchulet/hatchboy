module PaymentsHelper

  def company_payments_amount company, in_date = nil
    PaymentRecipient.where(payment_id: (in_date ? company.payments.sent_and_marked.where(created_at: in_date) : company.payments.sent_and_marked)).sum(:amount)
  end
end
