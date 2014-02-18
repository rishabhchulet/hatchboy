class PostReceiver < ActiveRecord::Base
  belongs_to :receiver, polymorphic: true
  belongs_to :post
end
