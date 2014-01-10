FactoryGirl.define do
  
  sequence :source_project_uid do |time|
    "HAT00#{time}"
  end

  factory :teams_sources do
    association :team
    source { create :authorized_jira_source, company: team.company }
    uid { generate :source_project_uid }
  end  
  
end