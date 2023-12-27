module SlideHub
  module Cloud
    module Queue
      class Message
        attr_accessor :id, :body, :handle

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
          @messages.count.positive?
        end
      end
    end
  end
end
