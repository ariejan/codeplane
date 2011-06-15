module Codeplane
  module Resource
    class Thing < Base
      attr_reader :id, :user
      attr_accessor :name, :created_at

      def attributes
        {
          :thing => {
            :name => name
          }
        }
      end
    end
  end
end
