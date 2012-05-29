require "savon"

require "bronto/base"
require "bronto/contact"
require "bronto/delivery"
require "bronto/field"
require "bronto/filter"
require "bronto/list"
require "bronto/message"
require "bronto/version"

require "core_ext/array"
require "core_ext/object"
require "core_ext/string"

module Bronto
  class Errors
    attr_accessor :messages

    def initialize
      self.messages = {}
    end

    def add(code, message)
      messages[code] = message
    end

    def clear; messages.clear; end
    def length; messages.length; end
    def count; messages.count; end

    def to_a(include_codes = true)
      messages.map { |k,v| include_codes ? "#{v} (#{k})" : v }
    end
  end
end
