class JiraSource <  Source
  
  validate :connection, :on => :create
  
  private
  
  def connection
    debugger
    123
  end
  
end
