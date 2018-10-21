# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :imported_work_log, class: WorkLog do
    team { @team = create(:team) }
    source { @source = create :authorized_jira_source, company: team.company }
    uid_in_source { "HAT#{rand(200)}"}
    issue { Faker::Lorem.sentence }
    on_date { rand(30).days.ago }
    time { rand(16) * 60 * 60 * 30 }
    comment { Faker::Lorem.sentence }
    user { nil }
  end

  factory :work_log, class: WorkLog do
    team { @team = create(:team) }
    source { nil }
    uid_in_source { nil }
    issue { Faker::Lorem.sentence }
    on_date { rand(30).days.ago }
    time { rand(16) * 60 * 60 * 30 }
    comment { Faker::Lorem.sentence }
    user { create :user  }
  end

end

