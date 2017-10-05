module EmailAutomation::EmailAutomated
  extend ActiveSupport::Concern

  included do
    has_many :email_automations, as: :email_automated, class_name: "EmailAutomation::EmailAutomation"
    after_create :email_automation_init
    scope :email_automation, (-> {})

    def email_automation_init
      email_automation_types.each do |automation_type|
        automation = EmailAutomation::EmailAutomation.new(
          automation_type: automation_type,
          email_automated_id: id,
          email_automated_type: self.class.name
        )
        if automation.save
          automation.state_label = email_automation_initial_state_label
        end
      end
    end

    def email_automation_initial_state_label
      '1'
    end

    def email_automation_finish_state_label
      'END'
    end

    def email_automation_determine_state_label(automation_type)
      # apply your logic
      try(:ea_determine_state_label, automation_type) || email_automation_initial_state_label
    end

    def email_automation_mandrill_data(automation)
      try(:ea_mandrill_data, automation) || { id: try(:id), name: try(:name) }
    end

    def email_automation_mandrill_to(automation)
      try(:ea_mandrill_to, automation) ||
        EmailAutomation.configuration.from_email
    end

    def email_automation_mandrill_template(automation)
      try(:ea_mandrill_template, automation) || 'template-slug'
    end

    def email_automation_types
      # list automation types for initial automation creation
      # the list may be conditional
      try(:ea_types) || []
    end

    def email_automation_handle_automation_allowed?(automation)
      allowed = try(:ea_handle_automation_allowed?, automation)
      allowed.nil? || !allowed.nil? && allowed
    end

    def email_automation_handle_automation(automation)
      if !email_automation_handle_automation_allowed?(automation)
        automation.state.handled!
      elsif automation.state &&
            automation.state_label != email_automation_initial_state_label &&
            automation.state_label != email_automation_finish_state_label &&
            !automation.state.handled? &&
        begin
          EmailAutomationMailer.automation_email(
            to: email_automation_mandrill_to(automation),
            template: email_automation_mandrill_template(automation),
            data: email_automation_mandrill_data(automation)
          ).deliver_now

          puts "SENDING EMAIL"
          pp ({ to: email_automation_mandrill_to(automation),
                template: email_automation_mandrill_template(automation),
                data: email_automation_mandrill_data(automation)
              })
          automation.state.handled!
        rescue => e
          pp e.message
        end
      end
    end

    def email_automation_handle_automations
      email_automations.each do |automation|
        next if automation.state_label == email_automation_finish_state_label
        email_automation_handle_automation(automation)
      end
    end

    def email_automation_update_automation(automation)
      new_state_label = email_automation_determine_state_label(automation.automation_type)
      if new_state_label != automation.state_label
        automation.state_label = new_state_label
      end
    end

    def email_automation_update_automations
      email_automations.each do |automation|
        next if automation.state_label == email_automation_finish_state_label
        email_automation_update_automation(automation)
      end
    end
  end
end
