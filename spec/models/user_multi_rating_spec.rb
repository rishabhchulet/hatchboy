require 'spec_helper'

describe UserMultiRating do
  before do
    company = create :company
    @rater = create :user, company: company
    @rated = create :user, company: company
  end

  context "Class object" do
    it { should belong_to :rated }
    it { should belong_to :rater }

    it "scope current_period should not contain old ratings" do
      rating = @rater.user_multi_ratings.create(rated_id: @rated.id, score: 1, aspect_code: USER_MULTI_RATING_ASPECTS.keys.first)
      old_rating = @rater.user_multi_ratings.create(rated_id: @rated.id, score: 1, aspect_code: USER_MULTI_RATING_ASPECTS.keys.first, date_period: (UserMultiRating::RATE_TIMEOUT+1).month.ago.at_beginning_of_month)
      described_class.current_period.should_not include old_rating
      described_class.current_period.should include rating
    end
  end

  context "while validation" do
    let(:user_multi_rating) { @rater.user_multi_ratings.build(rated_id: @rated.id, score: 1, aspect_code: USER_MULTI_RATING_ASPECTS.keys.first) }
    
    subject { user_multi_rating }
    
    it { should validate_presence_of :rated_id}
    it { should validate_presence_of :rater_id}
    it { should validate_presence_of :score}
    it { should validate_presence_of :aspect_code}
    it { should be_valid }

    context "when score is out of the range" do
      before { user_multi_rating.score = UserMultiRating::MAX_RATING + 1 }
      it { should_not be_valid }
    end

    context "when apect code does not exist" do
      before { user_multi_rating.aspect_code = "not_existing_aspect" }
      it { should_not be_valid }
    end

    context "when dublicate with same rater, rated, aspect and date period" do
      before do
        new_user_multi_rating = user_multi_rating.dup
        new_user_multi_rating.save!
      end
      it { should_not be_valid }
    end
  end

  context "while creation" do
    
    it "should set default atributes before validation" do
      rating = @rater.user_multi_ratings.build(rated_id: @rated.id, score: 1, aspect_code: USER_MULTI_RATING_ASPECTS.keys.first)
      rating.date_period.should be nil
      rating.valid?
      rating.date_period.should eq (UserMultiRating::RATE_TIMEOUT-1).month.ago.at_beginning_of_month
    end

    it "should call create average rating method when all aspects are exist" do
      ratings = USER_MULTI_RATING_ASPECTS.keys.map{|code| @rater.user_multi_ratings.build(rated_id: @rated.id, score: 1, aspect_code: code)}
      last_rating = ratings.pop
      ratings.each do |rating|
        rating.should_not_receive :create_avg_rating
        rating.save!
      end
      last_rating.should_receive(:create_avg_rating).once
      last_rating.save!
    end
  end
end
