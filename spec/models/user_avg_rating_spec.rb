require 'spec_helper'

describe UserAvgRating do
  before do
    company = create :company
    @rater = create :user, company: company
    @rated = create :user, company: company
  end

  context "Class object" do
    it { should belong_to :rated }
    it { should belong_to :rater }

    it "scope current_period should not contain old ratings" do
      rating = @rater.user_avg_ratings.create(rated_id: @rated.id, avg_score: 1)
      old_rating = @rater.user_avg_ratings.create(rated_id: @rated.id, avg_score: 1, date_period: (UserMultiRating::RATE_TIMEOUT+1).month.ago.at_beginning_of_month)
      described_class.current_period.should_not include old_rating
      described_class.current_period.should include rating
    end
  end

  context "while validation" do
    let(:user_avg_rating) { @rater.user_avg_ratings.build(rated_id: @rated.id, avg_score: 1) }
    
    subject { user_avg_rating }
    
    it { should validate_presence_of :rated_id}
    it { should validate_presence_of :rater_id}
    it { should validate_presence_of :avg_score}
    it { should be_valid }

    context "when score is out of the range" do
      before { user_avg_rating.avg_score = UserMultiRating::MAX_RATING + 1 }
      it { should_not be_valid }
    end

    context "when dublicate with same rater, rated and date period" do
      before do
        new_user_avg_rating = user_avg_rating.dup
        new_user_avg_rating.save!
      end
      it { should_not be_valid }
    end
  end

  context "while creation" do
    
    it "should set default atributes before validation" do
      rating = @rater.user_avg_ratings.build(rated_id: @rated.id, avg_score: 1)
      rating.date_period.should be nil
      rating.valid?
      rating.date_period.should eq (UserMultiRating::RATE_TIMEOUT-1).month.ago.at_beginning_of_month
    end

    it "should update user rating" do
      rating = @rater.user_avg_ratings.build(rated_id: @rated.id, avg_score: 1)
      rating.should_receive(:update_user_rating).once
      rating.save!
    end
  end
end
