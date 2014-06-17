require 'active_support'

module ActiveRecord
  class Base
    # Use this method to find or create records that have uniqueness constraints enforced by the database.
    # After calling the AR find_or_create_by method it queries the preexisting or created record by the attributes
    # provided, thereby ensuring that a concurrently created record is returned when a AR RecordNotUnique error is
    # raised. When no record can be found, because for instance validations fail on create, the created object
    # containing the validation errors is returned instead.
    def self.uniq_find_or_create_by(attributes, &block)
      find_or_create_by(attributes, &block)
    # When a real race condition occurs, activerecord has no clue about a uniqueness constraint
    # being violated (this is exactly why validates :attribute, uniqueness: true does not work
    # for these cases) and a plain Mysql2::Error exception is raised instead of
    # ActiveRecord::RecordNotUnique
    rescue Mysql2::Error => exception
      find_by(attributes) || raise(exception)
    rescue ActiveRecord::RecordNotUnique => exception
      find_by(attributes) || raise(exception)
    end

    # Use this method if you want an exception to be raised when creating a new record fails due to some validation
    # error other than uniqueness.
    def self.uniq_find_or_create_by!(attributes, &block)
      find_or_create_by!(attributes, &block)
    # When a real race condition occurs, activerecord has no clue about a uniqueness constraint
    # being violated (this is exactly why validates :attribute, uniqueness: true does not work
    # for these cases) and a plain Mysql2::Error exception is raised instead of
    # ActiveRecord::RecordNotUnique
    rescue Mysql2::Error => exception
      find_by(attributes) || raise(exception)
    rescue ActiveRecord::RecordNotUnique => exception
      find_by(attributes) || raise(exception)
    rescue ActiveRecord::RecordInvalid => exception
      find_by(attributes) || raise(exception)
    end
  end
end
