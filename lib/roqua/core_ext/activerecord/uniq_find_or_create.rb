require 'active_support'

module ActiveRecord
  class Base
    def self.uniq_find_or_create_by(attributes, &block)
      record = find_or_create_by(attributes, &block)
    rescue ActiveRecord::RecordNotUnique
    ensure
      return find_by(attributes) || record
    end
  end
end
