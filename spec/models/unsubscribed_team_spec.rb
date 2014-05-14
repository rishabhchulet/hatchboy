require 'spec_helper'

describe UnsubscribedTeam do
  specify do
    should belong_to :user
    should belong_to :team
  end
end
