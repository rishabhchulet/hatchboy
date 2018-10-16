namespace :hatchboy do
  task :generate_payments, [:company_id] => :environment do |t, args|
    companies = args[:company_id] ? Company.where(id: args[:company_id]) : Company.all
    companies.each do |company|
      start_date = Date.today.beginning_of_year
      begin
        start_date += 1.week
        payment = Payment.create(company: company, created_at: (start_date + rand(0..2).day), status: "sent", description: "testing", created_by: company.users.shuffle.first)
        company.users.each do |user|
          payment.recipients.create(user: user, amount: rand(1..20))
        end
      end while Date.today.next_month > start_date
    end
  end
end