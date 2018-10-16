FactoryGirl.define do
  
  factory :help_link do
    sequence(:controller) { |n| "controller#{n}" }
    sequence(:action) { |n| "action#{n}" }
    link { "http://example.com" }
    video_link { "http://example.com" }
  end
end