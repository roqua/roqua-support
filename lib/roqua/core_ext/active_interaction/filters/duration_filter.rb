I18n.backend.store_translations :en, active_interaction: {
  types: { duration: 'Duration' }
}

module ActiveInteraction
  class Base
    # @!method self.duration(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that the value passed to
    #     the attributes is a  ActiveSupport::Duration.
    #   Value can be a hash with a value and unit key
    #
    #   @!macro filter_method_params
    #   @option options [Boolean] :strip (false) Make nil if value is 0.
    #
    #   @example
    #     duration :first_name
    #   @example
    #     duration :first_name, strip: true
  end

  # @private
  class DurationFilter < Filter
    register :duration

    def cast(value)
      case value
      when ActiveSupport::Duration
        (value == 0 && strip?) ? super(nil) : value
      when Hash
        if value[:value].present? && (value[:value].to_i != 0 || !strip?)
          value[:value].to_i.send(value[:unit])
        else
          super(nil)
        end
      else
        super
      end
    end

    private

    def strip?
      options.fetch(:strip, false)
    end
  end
end
