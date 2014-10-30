require "roqua-support/version"
require "roqua/support"

module Roqua
  module Responders
    autoload :ApiErrorsResponder, 'roqua/responders/api_errors_responder'
    autoload :ActiveInteractionAwareResponder, 'roqua/responders/active_interaction_aware_responder'
  end
end
