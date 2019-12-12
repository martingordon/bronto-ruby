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
      api_key = api_key || self.api_key

      resp = request(:read, body)

      Array.wrap(resp[:return]).map { |hash| new(hash) }
    end

    def initialize(options = {})
      super(options)
      self.recipients = []
    end

    def to_hash
      start_val = if start.is_a?(String)
        start
      elsif start.respond_to?(:strftime)
        start.strftime("%Y-%m-%dT%H:%M:%S.%6N%:z")
      else
        start
      end

      hash = {
        id: id, start: start_val, message_id: message_id, type: type, from_email: from_email, from_name: from_name,
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

      self.recipients << { id: id, type: type }
    end
  end
end
