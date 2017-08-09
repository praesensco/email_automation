module EmailAutomation
  class EmailAutomation < ActiveRecord::Base
    belongs_to :email_automated, polymorphic: true
    has_many :states, class_name: "EmailAutomation::EmailAutomationState"

    def state_label=(label)
      return if label.blank?
      if states.empty? || state_label != label
        states << EmailAutomationState.new(label: label)
        state_label(true)
      end
    end

    def state_label(reload = false)
      if reload
        @state_label = state_label_load
      else
        @state_label ||= state_label_load
      end
    end

    def state(reload = false)
      if reload
        @state = state_load
      else
        @state ||= state_load
      end
    end

    private

    def state_label_load
      states.last.present? ? state.label : ''
    end

    def state_load
      states.last
    end
  end
end
