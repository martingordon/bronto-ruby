module Bronto
  class Contact < Base
    attr_accessor :email, :fields, :lists

    # Finds contacts based on the `filter` (Bronto::Filter object).
    # * `page_number` is the page of contacts to request. Bronto doesn't specify how many contacts are returned per page,
    #    only that you should keep increasing the number until no more contacts are returned.
    # * `fields` can be an array of field IDs or an array of Field objects.
    # * `include_lists` determines whether to include the list IDs each contact belongs to.
    def self.find(filter, page_number = 1, fields = nil, include_lists = false)
      body = { filter: filter.to_hash, page_number: page_number }

      body[:fields] = Array(fields).map { |f| f.is_a?(Field) ? f.id : f } if Array(fields).length > 0
      body[:include_lists] = include_lists

      resp = request(:read) do
        soap.body = body
      end

      Array(resp[:return]).map { |hash| new(hash) }
    end

    def to_hash
      if id.present?
        { id: id, email: email, fields: fields.map(&:to_hash) }
      else
        { email: email, fields: fields.map(&:to_hash) }
      end
    end
  end
end
