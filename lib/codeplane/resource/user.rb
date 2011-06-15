module Codeplane
  module Resource
    class User < Base
      attr_reader :id, :name, :email, :username, :storage, :usage, :time_zone, :created_at

      undef_method :attributes
      undef_method :save
      undef_method :resource_path
    end
  end
end
