# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jira_source do
    association :company
    name { Faker::Company.name}
    url { "http://example.com"}
    consumer_key { SecureRandom.hex(16) }
    access_token { SecureRandom.hex(16) }
    access_token_secret { SecureRandom.hex(16) }
    private_key do
      #system("openssl req -x509 -nodes -newkey rsa:1024 -sha1 -keyout /tmp/rsakey.pem -out /tmp/rsacert.pem")
      #system("cat /tmp/rsacert.pem")
      "valid_ssl_certificate"
    end
    
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
