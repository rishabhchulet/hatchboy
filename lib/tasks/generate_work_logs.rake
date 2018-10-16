namespace :hatchboy do
  task :generate_work_logs, [:company_id] => :environment do |t, args|
    companies = args[:company_id] ? Company.where(id: args[:company_id]) : Company.all
    companies.each do |company|
      company.users.each do |user|
        (Date.today.beginning_of_year..Date.today.next_month).each do |date|
          user.worklogs.create(time: rand(1..8), team: user.teams.first, on_date: date)
          user.worklogs.create(time: rand(1..4), team: user.teams.shuffle.first, on_date: date)
        end
      end
    end
  end
end