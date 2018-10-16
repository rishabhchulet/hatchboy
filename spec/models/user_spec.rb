require 'spec_helper'

describe User do

  it { should belong_to :company }
  it { should have_many :teams }

  it { should have_many :user_multi_ratings }
  it { should have_many :user_avg_ratings }
  it { should have_many :multi_ratings_by_users }
  it { should have_many :avg_ratings_by_users }

  it { should validate_presence_of :name}

  it { should validate_presence_of :company}

  it { should have_one(:account).class_name("Account") }
  it { should accept_nested_attributes_for(:company).allow_destroy(true) }
  it { should accept_nested_attributes_for(:account).allow_destroy(true) }

  it { should have_one(:subscription) }
  it { should have_many(:unsubscribed_teams) }

  it { should validate_presence_of(:company) }
  it { should validate_presence_of(:name) }

  it "should be possible to create user without account" do
    user = described_class.new name: Faker::Name.name
    user.company = create :company, created_by: user
    user.should be_valid
    user.save
    User.exists?(user).should eq true
    Company.exists?(user.company).should eq true
  end

  it "should create company from company_attributes" do
    @attr = { name: Faker::Name.name, company_attributes: { name: Faker::Company.name }}
    user = described_class.create(@attr)
    user.should be_valid
    user.name.should eq @attr[:name]
    user.company.name.should eq @attr[:company_attributes][:name]
  end

  it "should validate email format" do
    user = described_class.create(name: "foo", company: create(:company))
    user.should be_valid
    user.contact_email = "wrond@email"
    user.should_not be_valid
    user.contact_email = "valid@email.com"
    user.should be_valid
  end

  context "multi rating" do
    before do
      company = create :company
      @rater_user = described_class.create(name: "foo", company: company)
      @rated_user = described_class.create(name: "foo", company: company)
    end

    it "should update rating" do
      @rater_user.user_avg_ratings.create(rated: @rated_user, avg_score: 1)
      @rated_user.update_rating!
      @rated_user.rating.should eq 1
    end

    it "should possible to rate" do
      @rater_user.can_rate?(@rated_user).should be true
      USER_MULTI_RATING_ASPECTS.slice(0..(USER_MULTI_RATING_ASPECTS.count-1)).keys.each{|code| @rater_user.user_multi_ratings.create(rated_id: @rated_user.id, score: 1, aspect_code: code)}
      @rater_user.can_rate?(@rated_user).should be true
    end

    it "should not possible to rate" do
      USER_MULTI_RATING_ASPECTS.keys.each{|code| @rater_user.user_multi_ratings.create(rated_id: @rated_user.id, score: 1, aspect_code: code)}
      @rater_user.can_rate?(@rated_user).should be false
    end
  end

end
