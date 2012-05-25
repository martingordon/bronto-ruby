module Bronto
  class Field < Base
    attr_accessor :id, :name, :label, :type, :visibility

    def to_hash
      hash = { name: name, label: label, type: type, visibility: visibility }
      hash[:id] = id if id.present?
      hash
    end
  end
end
