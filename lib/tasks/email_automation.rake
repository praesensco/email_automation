namespace :email_automation do
  desc "Run Email Automation"
  task run: :environment do
    EmailAutomation.configuration.automated_classes.each do |automated_class|
      automated_class.email_automation.each do |object|
        object.email_automation_update_automations
        object.email_automation_handle_automations
      end
    end
  end
end
