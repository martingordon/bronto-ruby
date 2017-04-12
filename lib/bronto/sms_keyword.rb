module Bronto
  class SMSKeyword < Base
    attr_accessor :name, :description, :subscriber_count, :frequency_cap, :date_created,
                  :scheduled_delete_date, :confirmation_message, :message_content, :keyword_type

    def self.plural_class_name
      'sms_keywords'
    end

    def self.object_name
      'keyword'
    end

    def initialize(options = {})
      super(options)
      self.subscriber_count ||= 0
      self.frequency_cap    ||= 30
      self.keyword_type     ||= "basic"
    end

    def add_to_keyword(*contacts)
      begin
        add_to_keyword!(contacts)
      rescue Bronto::Error => e
        false
      end
    end

    # Adds the given contacts to this SMS Keyword.
    def add_to_keyword!(*contacts)
      return false if !self.id.present?
      contacts = contacts.flatten

      # The block below is evaluated in a weird scope so we need to capture self as _self for use inside the block.
      _self = self

      resp = request("add_to_sms_keyword", {keyword: { id: _self.id }, contacts: contacts.map { |c| { id: c.id } }})

      errors = Array.wrap(resp[:return][:results]).select { |r| r[:is_error] }
      errors.each do |error|
        raise Bronto::Error.new(error[:error_code], error[:error_string])
      end

      true
    end

    # Removes the given contacts from this SMS Keyword.
    def remove_from_keyword(*contacts)
      return false if !self.id.present?
      contacts = contacts.flatten

      # The block below is evaluated in a weird scope so we need to capture self as _self for use inside the block.
      _self = self

      resp = request("remove_from_sms_keyword", {keyword: { id: _self.id }, contacts: contacts.map { |c| { id: c.id } } })

      Array.wrap(resp[:return][:results]).select { |r| r[:is_error] }.count == 0
    end

    def subscriber_count=(new_val)
      @subscriber_count = new_val.to_i
    end


    def to_hash
      hash = { name: name, description: description, frequency_cap: frequency_cap,
               confirmation_message: confirmation_message,
               message_content: message_content, keyword_type: keyword_type }
      hash[:id] = id if id.present?
      hash.compact
    end
  end
end