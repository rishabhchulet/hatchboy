namespace :hatchboy do
  task :generate_user_ratings, [:company_id] => :environment do |t, args|
    companies = args[:company_id] ? Company.where(id: args[:company_id]) : Company.all
    companies.each do |company|
      company.users.each do |user|
        company.users.each do |rated_user|
          if user != rated_user
            (Date.today.beginning_of_year..1.month.ago).select {|d| d.day == 1}.each do |period|
              begin
                user.user_avg_ratings.create(rated: rated_user, avg_score: rand(1..10), date_period: period)
              rescue Exception
                #handle failure
              end
            end
          end
        end
      end
    end
  end
end