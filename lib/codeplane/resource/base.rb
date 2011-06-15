module Codeplane
  module Resource
    class Base
      # The base resource path provided by the
      # Codeplane::Collection instance.
      #
      attr_accessor :collection_resource_path

      # Initialize a new resource. All attributes must be defined on
      # each Resource class.
      #
      def initialize(attributes = {})
        assign_attributes(attributes)
      end

      # Check if resource is valid.
      # This method DOES NOT make any API call. It only checks if
      # the Codeplane::Resource::Base#errors method returns any error message.
      #
      def valid?
        errors.empty?
      end

      # Check if this resource actually exist.
      # This method DOES NOT make any API call. It only checks if
      # the Codeplane::Resource::Base#id attribute has been set.
      #
      def new_record?
        id.nil?
      end

      # Do a API call to create or update this resource. It do a POST request if
      # it's a Codeplane::Resource::Base#new_record? or a PUT request otherwise.
      #
      def save
        if new_record?
          response = Codeplane::Request.post(resource_path, attributes)
        else
          response = Codeplane::Request.put(resource_path, attributes)
        end

        assign_attributes(response.payload)
      end

      # Do a API call to destroy this resource. It will DELETE to the specified
      # Codeplane::Resource::Base#resource_path with the +id+ attribute.
      #
      def destroy
        raise Codeplane::UnsavedResourceError, "the id attribute is not set" if new_record?
        Codeplane::Request.delete(resource_path) && true
      end

      # Errors while creating or updating a resource will be returned
      # by this method.
      #
      def errors
        @errors ||= []
      end

      # Return the resource considering the +id+ attribute for
      # existing resources.
      #
      def resource_path
        parts = [collection_resource_path]
        parts << id.to_s unless new_record?
        File.join(*parts)
      end

      # Return a hash for POST/PUT body.
      #
      def attributes
        raise Codeplane::AbstractMethodError, "the #attributes method needs to be implemented"
      end

      private
      def build_created_at(stamp)
        Time.parse(stamp) if stamp
      end

      def build_user(attributes)
        User.new(attributes) if attributes.kind_of?(Hash)
      end

      def assign_attributes(attributes)
        attributes.each do |name, value|
          value = send("build_#{name}", value) if respond_to?("build_#{name}", true)
          instance_variable_set("@#{name}", value)
        end
      end
    end
  end
end
