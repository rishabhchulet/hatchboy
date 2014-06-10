module WorkLogsHelper

  def company_work_logs company, in_date = nil
    worklogs = WorkLog.where(user_id: company.users)
    worklogs = worklogs.where(created_at: in_date) if in_date
    worklogs.sum(:time)
  end
end
