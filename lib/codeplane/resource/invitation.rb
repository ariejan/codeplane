module Codeplane
  module Resource
    class Invitation < Base
      attr_reader :errors, :email
      undef_method :attributes
    end
  end
end
