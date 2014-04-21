namespace :hatchboy do
  task :generate_work_logs => :environment do
    users = User.all
    users.each do |user|
      created_time = Time.at(10.month.ago.to_f + rand * (Time.now.to_f - 10.month.ago.to_f)).to_time
      100.times do
        user.worklogs.create(time: rand(1..20).hour, team: user.teams.sample, on_date: created_time)
      end
    end
  end
end