require "savon"

require_relative "bronto/base"
require_relative "bronto/contact"
require_relative "bronto/delivery"
require_relative "bronto/field"
require_relative "bronto/filter"
require_relative "bronto/list"
require_relative "bronto/message"
require_relative "bronto/message_folder"
require_relative "bronto/sms_keyword"
require_relative "bronto/version"

require_relative "core_ext/array"
require_relative "core_ext/hash"
require_relative "core_ext/object"
require_relative "core_ext/string"

module Bronto
  class Error < StandardError
    attr_accessor :code, :message

    def initialize(code, message)
      self.code = code
      self.message = message
    end

    def code=(new_code)
      @code = new_code.to_i
    end

    def to_s
      "#{code}: #{message}"
    end
  end

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
