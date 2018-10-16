require 'webmock/rspec'

WebMock.disable_net_connect!(:allow_localhost => true)

module JIRAHelper

  def get_mock_response(file, value_if_file_not_found = false)
    begin
      file.sub!('?', '_') # we have to replace this character on Windows machine
      File.read(File.join(Rails.root.to_s, "/spec/fixtures/jira_mock_responses/", file))
    rescue Errno::ENOENT => e
      raise e if value_if_file_not_found == false
      value_if_file_not_found
    end
  end

end
