module Codeplane
  module Resource
    class Repository < Base
      attr_reader :id, :errors, :usage, :created_at, :user, :uri
      attr_accessor :name

      def collaborators
        @collaborators ||= Codeplane::Collection.new(
          :resource_path       => "/repositories/#{id}/collaborators",
          :resource_class_name => "User",
          :extension           => Codeplane::Resource::Extensions::Collaborator,
          :parent              => self
        )
      end

      # Detect if repository is owned by current API user.
      #
      def mine?
        user && user.username == Codeplane.username
      end

      # Override +destroy+ method and warn user when trying to remove
      # a repository that his just collaborating.
      #
      def destroy
        raise Codeplane::OwnershipError, "you can only remove your own repositories" unless mine?
        super
      end

      def attributes
        {
          :repository => {
            :name => name
          }
        }
      end
    end
  end
end
