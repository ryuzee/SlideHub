module SlideHub
  module Cloud
    module Queue
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
