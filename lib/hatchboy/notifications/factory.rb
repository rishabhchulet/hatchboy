module Hatchboy
  module Notifications
    class Factory
      attr_reader :company, :object, :owner, :recipients, :render

      def initialize activity
        @company = Company.where(id: activity.company_id).first
        @object = activity.trackable_type.constantize.where(id: activity.trackable_id).first
        @owner = activity.owner_type.constantize.where(id: activity.owner_id).first
      end

      def send recipients, render

      end

      def self.get activity
        model_name, action = activity.key.split '.'
        "Hatchboy::Notifications::#{model_name.camelize}".constantize.new action, activity
      end
    end
  end
end

  # t.integer  "company_id"
  # t.integer  "trackable_id"
  # t.string   "trackable_type"
  # t.integer  "owner_id"
  # t.string   "owner_type"
  # t.string   "key"
  # t.text     "parameters"
  # t.text     "comments"
  # t.integer  "recipient_id"
  # t.string   "recipient_type"
  # t.datetime "created_at"
  # t.datetime "updated_at"