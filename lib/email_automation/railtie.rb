module EmailAutomation
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/email_automation.rake'
    end
  end
end
