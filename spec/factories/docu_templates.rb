# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :docu_template do

    ignore do
      docu_signs_count 1
    end

    user
    company { user.company }
    title { Faker::Lorem.sentence }
    template_key { SecureRandom.uuid }
    document Rack::Test::UploadedFile.new( Rails.root.join("spec/fixtures/documents/example.pdf"), "application/pdf")
    recipients "not_blank"

    after(:build) do |dt, evaluator|
      dt.class.skip_callback(:validation, :before, :set_docusigns)
      dt.class.skip_callback(:validation, :before, :get_template)
    end

    before :create do |dt, evaluator|
      dt.docu_signs = FactoryGirl.build_list(:docu_sign, evaluator.docu_signs_count, company: dt.company)
    end

  end
end
