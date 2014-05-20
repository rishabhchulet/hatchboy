require 'spec_helper'

describe SubscriptionsController do

  let(:user) { create :user, :with_subscription }

  before do
    user.create_subscription
    sign_in user.account
  end
  
  describe "while updating" do
    before { user.subscription.update_attributes({user_was_added: false}) }

    it "should desrement the UnsubscribedTeam count" do
      put :update, id: user.subscription.id, subscription: { user_was_added: 1 }
      user.subscription.reload.user_was_added.should be true
    end

    it "should respond with success" do
      put :update, id: user.subscription.id, subscription: { user_was_added: 1 }
      expect(response).to redirect_to account_path
    end
  end

  describe "while unsubscribing" do
    it "should unsubscribe user from action" do
      get :unsubscribe, user_was_added: 1
      user.subscription.reload.user_was_added.should be false
    end

    it "should respond with success" do
      get :unsubscribe, user_was_added: 1
      expect(response).to redirect_to account_path
    end
  end
end