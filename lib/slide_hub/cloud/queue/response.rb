module SlideHub
  module Cloud
    module Queue
      class Message
        attr_accessor :id
        attr_accessor :body
        attr_accessor :handle

        def initialize(id, body, handle)
          @id = id
          @body = body
          @handle = handle
        end
      end

      class Response
        attr_reader :messages
        def initialize
          @messages = []
        end

        def add_message(id, body, handle)
          msg = Message.new(id, body, handle)
          @messages.push(msg)
        end

        def exist?
          @messages.count > 0
        end
      end
    end
  end
end
