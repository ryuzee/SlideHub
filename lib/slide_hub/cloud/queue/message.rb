module SlideHub
  module Cloud
    module Queue
      # キューから受け取った 1 件のメッセージ
      class Message
        attr_accessor :id, :body, :handle

        def initialize(id, body, handle)
          @id = id
          @body = body
          @handle = handle
        end
      end
    end
  end
end
