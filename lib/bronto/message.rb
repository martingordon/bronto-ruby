module Bronto
  class Message < Base
    attr_accessor :name, :status, :message_folder_id, :content

    def initialize(options = {})
      super(options)
      self.content = { }
    end

    def to_hash
      hash = { id: id, name: name, status: status, message_folder_id: message_folder_id, content: content.values.map(&:to_hash) }
      [ :status, :id, :message_folder_id ].each do |f|
        hash.delete(f) if send(f).blank?
      end
      hash
    end

    def add_content(type, subject, content)
      self.content[type] = Content.new(type, subject, content)
    end

    class Content
      attr_accessor :type, :subject, :content

      def initialize(type, subject, content)
        self.type = type
        self.subject = subject
        self.content = content
      end

      def to_hash
        { type: type, subject: subject, content: content }
      end
    end
  end
end
