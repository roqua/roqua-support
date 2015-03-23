I18n.backend.store_translations :nl, errors: {
  messages: { subset: 'bevat onbekende keuzes' }
}

class SubsetValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value
    unless value.all? { |element| options.fetch(:of).include? element }
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.subset'))
    end
  end
end
