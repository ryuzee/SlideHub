# See https://stackoverflow.com/questions/62045971/no-such-file-to-load-azure-storage-rb
module Azure
  module Storage
    module Core
      module Auth
        class SharedAccessSignature
        end
      end
    end
  end
end