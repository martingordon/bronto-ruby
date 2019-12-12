module Bronto
  class Contact < Base
    attr_accessor :email, :fields, :list_ids, :created, :modified, :status, :num_opens, :num_clicks, :num_sends
    # Finds contacts based on the `filter` (Bronto::Filter object).
    # * `page_number` is the page of contacts to request. Bronto doesn't specify how many contacts are returned per page,
    #    only that you should keep increasing the number until no more contacts are returned.
    # * `fields` can be an array of field IDs or an array of Field objects.
    # * `include_lists` determines whether to include the list IDs each contact belongs to.
    def self.find(filter = Bronto::Filter.new, page_number = 1, fields = nil, include_lists = false, api_key = nil)
      body = { filter: filter.to_hash, page_number: page_number }
      api_key = api_key || self.api_key

      body[:fields] = Array.wrap(fields).map { |f| f.is_a?(Bronto::Field) ? f.id : f } if Array(fields).length > 0
      body[:include_lists] = include_lists

      resp = request(:read, body)

      Array.wrap(resp[:return]).map { |hash| new(hash) }
    end

    def self.save(*objs)
      objs = objs.flatten
      api_key = objs.first.is_a?(String) ? objs.shift : self.api_key

      resp = request(:add_or_update, {plural_class_name => objs.map(&:to_hash)})

      objs.each { |o| o.errors.clear }

      Array.wrap(resp[:return][:results]).each_with_index do |result, i|
        if result[:is_error]
          objs[i].errors.add(result[:error_code], result[:error_string])
        else
          objs[i].id = result[:id]
        end
      end

      objs
    end

    def self.update(*objs)
      objs = objs.flatten
      api_key = objs.first.is_a?(String) ? objs.shift : self.api_key

      resp = request(:update, {plural_class_name => objs.map(&:to_hash)})

      objs.each { |o| o.errors.clear }

      Array.wrap(resp[:return][:results]).each_with_index do |result, i|
        if result[:is_error]
          objs[i].errors.add(result[:error_code], result[:error_string])
        else
          objs[i].id = result[:id]
        end
      end

      objs
    end

    def initialize(options = {})
      self.fields = {}
      fields = options.delete(:fields)
      Array.wrap(fields).each { |field| set_field(field[:field_id], field[:content]) }

      super(options)
    end

    def reload
      return false if self.email.blank?

      filter = Bronto::Filter.new
      filter.add_filter("email", "EqualTo", self.email)

      new_contact = self.class.find(filter, 1, self.fields, true, self.api_key).first

      self.id = new_contact.id
      self.fields = new_contact.fields
      self.list_ids = new_contact.list_ids

      true
    end

    def save
      self.class.save(self)
    end

    def to_hash
      obj = { email: email, fields: fields.values.map(&:to_hash) }
      obj.merge!(id: id) if id.present?
      obj.merge!(status: status) if status.present?
      obj
    end

    def set_field(field, value)
      id = field.is_a?(Bronto::Field) ? field.id : field
      self.fields[id] = Field.new(id, value)
    end

    def get_field(field)
      id = field.is_a?(Bronto::Field) ? field.id : field
      self.fields[id].try(:content)
    end

    class Field
      attr_accessor :field_id, :content

      def initialize(id, content)
        self.field_id = id
        self.content = content
      end

      def to_hash
        { field_id: field_id, content: content }
      end
    end
  end
end
