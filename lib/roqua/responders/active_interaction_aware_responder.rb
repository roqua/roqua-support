# For json and xml, will render the result of an active_interaction operation if no errors where present.
# Otherwise renders the interaction
module Roqua
  module Responders
    module ActiveInteractionAwareResponder
      def to_format
        if resource.is_a?(ActiveInteraction::Base)
          if resource.errors.empty?
            @resource = resource.result
            @resources[-1] = resource
          end
        end
        super
      end

      def json_resource_errors
        if !resource.is_a?(ActiveInteraction::Base) || resource.errors.empty?
          super
        else
          {:errors => resource.errors.as_json}
        end
      end
    end
  end
end
