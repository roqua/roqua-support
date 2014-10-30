# Scopes json errors to the object-class:
#
# @example
#   {errors: {person: name: ['blank']}}
#
# Does not play well with others, replaces json_resource_errors; when including multiple responders, ordering matters.
module Roqua
  module Responders
    module ApiErrorsResponder
      def json_resource_errors
        {:errors => {resource.class.name.underscore => resource.errors}}
      end
    end
  end
end
