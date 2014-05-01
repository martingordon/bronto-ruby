module Bronto
  class List < Base
    attr_accessor :name, :label, :active_count, :status, :visibility

    # Removes all contacts from the given lists.
    def self.clear_lists(*lists)
      lists = lists.flatten
      api_key = lists.first.is_a?(String) ? lists.shift : self.api_key

      resp = request(:clear, api_key) do
        soap.body = {
          list: lists.map { |l| { id: l.id } }
        }
      end

      lists.each { |l| l.reload }

      Array.wrap(resp[:return][:results]).select { |r| r[:is_error] }.count == 0
    end

    def initialize(options = {})
      super(options)
      self.active_count ||= 0
    end

    def add_to_list(*contacts)
      begin
        add_to_list!(contacts)
      rescue Bronto::Error => e
        false
      end
    end

    # Adds the given contacts to this list.
    def add_to_list!(*contacts)
      return false if !self.id.present?
      contacts = contacts.flatten

      # The block below is evaluated in a weird scope so we need to capture self as _self for use inside the block.
      _self = self

      resp = request("add_to_list") do
        soap.body = {
          list: { id: _self.id },
          contacts: contacts.map { |c| { id: c.id } }
        }
      end

      errors = Array.wrap(resp[:return][:results]).select { |r| r[:is_error] }
      errors.each do |error|
        raise Bronto::Error.new(error[:error_code], error[:error_string])
      end

      true
    end

    # Removes the given contacts from this list.
    def remove_from_list(*contacts)
      return false if !self.id.present?
      contacts = contacts.flatten

      # The block below is evaluated in a weird scope so we need to capture self as _self for use inside the block.
      _self = self

      resp = request("remove_from_list") do
        soap.body = {
          list: _self.to_hash,
          contacts: contacts.map(&:to_hash)
        }
      end

      Array.wrap(resp[:return][:results]).select { |r| r[:is_error] }.count == 0
    end

    def active_count=(new_val)
      @active_count = new_val.to_i
    end

    def to_hash
      hash = { name: name, label: label, status: status, visibility: visibility }
      hash[:id] = id if id.present?
      hash
    end
  end
end
