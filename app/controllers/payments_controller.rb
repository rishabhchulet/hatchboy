class PaymentsController < ApplicationController

  before_filter :authenticate_account!
  
  def new
    @payment = Payment.new
    @users = users_without_recipients
  end

  def index
    # render :nothing => true
    self.new
    @payments_prepared = account_company.payments.includes({recipients: :user}).where(status: Payment::STATUS_PREPARED).where.not(deleted: true).order(created_at: :desc)
    @payments_sent = account_company.payments.includes({recipients: :user}, :transactions).where(status: Payment::STATUS_SENT).where.not(deleted: true).order(created_at: :desc)
    @payments_deleted = account_company.payments.includes({recipients: :user}, :transactions).where(deleted: true).order(created_at: :desc)
  end

  def create
    @payment = account_company.payments.new(payment_params)
    @payment.created_by = current_account.user
    if @payment.save
      redirect_to :payments
    else
      @users = users_without_recipients
      render :new
    end
  end

  def show
    @payment = account_company.payments.where(id: params[:id]).first or not_found
  end

  def edit
    @payment = account_company.payments.where(id: params[:id]).where.not(deleted: true).first or not_found
    @users = users_without_recipients
  end

  def update
    @payment = account_company.payments.where(id: params[:id]).where.not(deleted: true).first or not_found
    @payment.created_by = current_account.user
    Payment.transaction do
      @payment.recipients.destroy_all if payment_params.has_key?(:recipients_attributes)
      @payment.assign_attributes(payment_params)
      @payment.save
    end

    unless @payment.errors.any?
      redirect_to :payments
    else
      @users = users_without_recipients
      render :edit
    end
  end

  def destroy
    @payment = account_company.payments.where(id: params[:id]).where.not(deleted: true).first or not_found
    @payment.deleted = true
    @payment.save!

    redirect_to :payments
  end
  
  private
  
  def payment_params
    params.require(:payment).permit(:description, recipients_attributes: [:user_id, :amount])
  end

  def users_without_recipients
    account_company.users - @payment.recipients.map(&:user)
  end

end
