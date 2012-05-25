module Bronto
  class List < Base
    attr_accessor :name, :label, :active_count, :status, :visibility

    # Removes all contacts from the given lists.
    def self.clear_lists(*lists)
      request(:clear) do
        soap.body = {
          lists: lists.map(&:to_hash)
        }
      end

      resp[:return][:results][:is_error]
    end

    # Adds the given contacts to this list.
    def add_to_list(*contacts)
      resp = request("add_to_list") do
        soap.body = {
          list: self.to_hash,
          contacts: contacts.map(&:to_hash)
        }
      end

      resp[:return][:results][:is_error]
    end

    # Removes the given contacts from this list.
    def remove_from_list(*contacts)
      resp = request("remove_from_list") do
        soap.body = {
          list: self.to_hash,
          contacts: contacts.map(&:to_hash)
        }
      end

      resp[:return][:results][:is_error]
    end

    def to_hash
      hash = { name: name, label: label, status: status, visibility: visibility }
      hash[:id] = id if id.present?
      hash
    end
  end
end
