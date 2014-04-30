namespace :hatchboy do
  task :generate_users_and_teams, [:company_id] => :environment do |t, args|
    companies = args[:company_id] ? Company.where(id: args[:company_id]) : Company.all
    companies.each do |company|
      teams = FactoryGirl.create_list(:team, 5, company: company)
      users = FactoryGirl.create_list(:user, 5, company: company)
      users.each do |user|
        teams.shuffle.slice(0..2).each{|team| user.user_teams.create(team: team)}
      end
    end
  end
end