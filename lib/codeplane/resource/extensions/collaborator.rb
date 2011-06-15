module Codeplane
  module Resource
    module Extensions
      module Collaborator
        def self.extended(base)
          class << base
            # undef_method :build
            undef_method :create
          end
        end

        def invite(email)
          response = Codeplane::Request.post(resource_path, :collaborator => {:email => email})
          Codeplane::Resource::Invitation.new(response.payload)
        end

        def remove(email)
          collaborator = parent.collaborators.all.find {|user| user.email == email}
          raise Codeplane::NotFoundError unless collaborator
          response = Codeplane::Request.delete(File.join(resource_path, collaborator.id.to_s))
        end
      end
    end
  end
end
