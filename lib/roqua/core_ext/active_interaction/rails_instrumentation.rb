require 'active_support/notifications.rb'

module RoquaRailsActiveInteractionInstrumentation
  def run
    ActiveSupport::Notifications.instrument 'operation.active_interaction',
                                            class_name: self.class.to_s.underscore do
      super
    end
  end
end

ActiveInteraction::Base.include RoquaRailsActiveInteractionInstrumentation
