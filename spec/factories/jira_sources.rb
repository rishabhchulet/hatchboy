# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jira_source do
    association company
    name { Faker::Company}
    type { "JiraSource" }
    url { "https://example.com:8080"}
    consumer_key { "123" }
    access_token "MyString"
    oauth_verifier "MyString"
    private_key "MyString"
    text "MyString"
  end
end
