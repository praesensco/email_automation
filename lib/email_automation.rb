require 'email_automation/version'

module EmailAutomation
  class Configuration
    attr_accessor :automated_classes
    attr_accessor :from_email
    attr_accessor :from_name

    def initialize
      @automated_classes = []
      @from_email = ''
      @from_name = ''
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end

require 'email_automation/app/models/email_automation_state.rb'
require 'email_automation/app/models/email_automation.rb'
require 'email_automation/app/models/concerns/email_automated.rb'
require 'email_automation/app/mailers/email_automation_mailer.rb'
require 'email_automation/railtie'
