namespace :hatchboy do
  task :generate_payments => :environment do
    companies = Company.all
    users = User.all
    companies.each do |company|
      users = company.users
      100.times do
        created_time = Time.at(5.month.ago.to_f + rand * (Time.now.to_f - 5.month.ago.to_f)).to_time
        payment = Payment.create(company: company, created_at: created_time, status: "sent", description: "test", created_by: users.first)
        users.each do |user|
          payment.recipients.create(user: user, amount: rand(1..20))
        end
      end
    end
  end
end