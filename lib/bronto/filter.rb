# Represents a filter (which is actually a set of filters).
# For more information, see the [Bronto documentation](http://community.bronto.com/api/v4/filters).

module Bronto
  class Filter
    attr_accessor :type, :fields

    def initialize
      self.fields = {}
    end

    def to_hash
      hash = { type: type || "AND" }
      hash.merge(fields)
    end

    # Accepts two or three arguments:
    #  1. Field name
    #  2. (optional) The operator to use (only available for certain fields; see the filter documentation).
    #  3. Value
    def add_filter(*args)
      raise ArgumentError, "wrong number of arguments (#{args.length} for 2..3)" if args.length != 2 and args.length != 3

      field = args.shift.to_sym
      self.fields[field] = [] unless self.fields.has_key?(field)

      if args.length == 1
        self.fields[field] << args.first
      else
        self.fields[field] << { operator: args.first, value: args.last }
      end

      self
    end
  end
end
