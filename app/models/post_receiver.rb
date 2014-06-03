class PostReceiver < ActiveRecord::Base
  include PublicActivity::Model
  tracked only: :create,
          owner: ->(controller, model) { controller && controller.current_user },
          company_id: ->(controller, post_receiver) { post_receiver.receiver.company_id },
          comments: ->(controller, post_receiver) { {subject: post_receiver.post.subject}.to_json }

  belongs_to :receiver, polymorphic: true
  belongs_to :post
end
