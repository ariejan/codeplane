module Codeplane
  class Client
    def repositories
      @repositories ||= Codeplane::Collection.new(
        :resource_path => "/repositories",
        :resource_class_name => "Repository",
        :parent => self
      )
    end

    def public_keys
      @public_keys ||= Codeplane::Collection.new(
        :resource_path => "/public_keys",
        :resource_class_name => "PublicKey",
        :parent => self
      )
    end
  end
end
