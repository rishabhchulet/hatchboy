# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :document do |current_document|
    current_document.owner { |a| a.association(:user) }
    doc_file File.open(Rails.root.to_s + "/spec/fixtures/images/test.png")
    doc_type nil
    doc_size nil
  end
end
