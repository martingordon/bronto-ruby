module Bronto
  class Delivery < Base
    attr_accessor :start, :message_id, :status, :type, :from_email, :from_name, :reply_email, :content, :recipients,
        :fields, :authentication, :reply_tracking

    # Finds contacts based on the `filter` (Bronto::Filter object).
    # * `page_number` is the page of contacts to request. Bronto doesn't specify how many contacts are returned per page,
    #    only that you should keep increasing the number until no more contacts are returned.
    # * `fields` can be an array of field IDs or an array of Field objects.
    # * `include_lists` determines whether to include the list IDs each contact belongs to.
    def self.find(filter = Bronto::Filter.new, page_number = 1, include_recipients = false, include_content = false, api_key = nil)
      body = { filter: filter.to_hash, page_number: page_number, include_recipients: include_recipients,
          include_content: include_content }

      resp = request(:read, api_key) do
        soap.body = body
      end

      Array.wrap(resp[:return]).map { |hash| new(hash) }
    end

    def initialize(options = {})
      super(options)
      self.recipients = []
    end

    def to_hash
      hash = {
        id: id, start: start, message_id: message_id, type: type, from_email: from_email, from_name: from_name,
        reply_email: reply_email, recipients: recipients, fields: fields, authentication: authentication,
        reply_tracking: reply_tracking
      }
      hash.each { |k,v| hash.delete(k) if v.blank? }
      hash
    end

    def add_recipient(*args)
      type = id = nil

      type, id = if args.is_a? Array and args.length == 2
        args
      else
        [args.first.class.to_s.split("::").last.downcase, args.first.id]
      end

      self.recipients << { type: type, id: id }
    end
  end
end
