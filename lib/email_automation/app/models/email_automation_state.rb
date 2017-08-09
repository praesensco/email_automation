module EmailAutomation
  class EmailAutomationState < ActiveRecord::Base
    belongs_to :email_automation, class_name: "EmailAutomation::EmailAutomation"
    default_scope { order(created_at: :asc) }

    def handled!
      update(handled_at: Time.zone.now)
    end

    def handled?
      handled_at.present?
    end
  end
end
