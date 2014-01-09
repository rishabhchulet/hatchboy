# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jira_source do
    association :company
    name { Faker::Company.name}
    url { "http://example.com"}
    consumer_key { "jira_consumer_key" }
    access_token { "valid_access_token" }
    access_token_secret { "valid_access_token_secret"}
    private_key { "valid_private_key" }
    
    factory :authorized_jira_source do
      after(:build) do |jira_source|
        client = JIRA::Client.new({ :auth_type => :basic, :use_ssl => false, site: jira_source.url })
        client.stub(:set_access_token).and_return({token: "foo", secret: "bar"})
        client.stub(:request_token).and_return({token: "foo", secret: "bar"})
        jira_source.stub(:client).and_return(client)
      end
      
    end
    
  end
end
