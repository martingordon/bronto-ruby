module Bronto
  class MessageFolder < Base
    attr_accessor :name #, :parentId, :parentName


    def self.plural_class_name
      'message_folders'
    end

    def to_hash
      if id.present?
        { :id => id, :name => name }
      else
        { :name => name }
      end
    end
  end
end

