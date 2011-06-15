module Codeplane
  module Resource
    class PublicKey < Base
      attr_reader :id, :name, :key, :fingerprint

      def attributes
        {
          :public_key => {
            :name => name,
            :key => key
          }
        }
      end
    end
  end
end
