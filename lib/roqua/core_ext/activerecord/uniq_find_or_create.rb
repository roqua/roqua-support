require 'active_support'

module ActiveRecord
  class Base
    # Use this method to find or create records that have uniqueness constraints enforced by the database.
    # After calling the AR find_or_create_by method it queries the preexisting or created record by the attributes
    # provided, thereby ensuring that a concurrently created record is returned when a AR RecordNotUnique error is
    # raised. When no record can be found, because for instance validations fail on create, the created object
    # containing the validation errors is returned instead.
    def self.uniq_find_or_create_by(attributes, &block)
      record = find_or_create_by(attributes, &block)
    rescue ActiveRecord::RecordNotUnique
    ensure
      return find_by(attributes) || record
    end

    # Use this method if you want an exception to be raised when creating a new record fails due to some validation
    # error other than uniqueness.
    def self.uniq_find_or_create_by!(attributes, &block)
      find_or_create_by!(attributes, &block)
    rescue ActiveRecord::RecordNotUnique
    rescue ActiveRecord::RecordInvalid => exception
    ensure
      return find_by(attributes) || raise(exception)
    end
  end
end
