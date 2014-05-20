require 'spec_helper'

describe UnsubscribedTeamsController do

  let(:user) { create :user }
  let(:team) { create :team, company: user.company }

  before do
    user.user_teams.create!(team: team)
    sign_in user.account
  end
  
  describe "while subscribing" do
    before { user.unsubscribed_teams.create!(team: team) }

    it "should desrement the UnsubscribedTeam count" do
      expect do
        xhr :delete, :subscribe, id: user.unsubscribed_teams.first.id
      end.to change(UnsubscribedTeam, :count).by(-1)
    end

    it "should respond with success" do
      xhr :delete, :subscribe, id: user.unsubscribed_teams.first.id
      expect(response).to be_success
    end
  end

  describe "while unsubscribing" do
    it "should increment the UnsubscribedTeam count" do
      expect do
        xhr :get, :unsubscribe, team_id: team.id
      end.to change(UnsubscribedTeam, :count).by(1)
    end
    
    it "should respond with success" do
      xhr :get, :unsubscribe, team_id: team.id
      expect(response).to be_success
    end
  end
end