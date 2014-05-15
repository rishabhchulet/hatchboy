FactoryGirl.define do
  factory :unsubscribed_team do
    user 
    team { create :team, company: user.company }

    before :create do |ut|
      ut.team.users << ut.user unless ut.team.users.include? ut.user
    end
  end
end
