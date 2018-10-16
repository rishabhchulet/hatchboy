module PostsHelper

  def get_latest_company_posts company, limit
    Post.where(user_id: company.users).order('created_at desc').limit(limit)
  end
end
