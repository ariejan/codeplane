module Codeplane
  class Collection
    include Enumerable

    # Set the API path for this resource.
    #
    attr_accessor :resource_path

    # Set the class that will be used to instantiate new
    # objects when calling Codeplane::Collection#build.
    #
    attr_accessor :resource_class_name

    # The parent object which instantiated the collection.
    #
    attr_accessor :parent

    # Also return items count by creating an
    # alias to the +count+ method.
    alias size count

    # Initialize a new collection, attributing each hash value
    # to its accessor.
    #
    def initialize(options = {})
      extend options.delete(:extension) if options[:extension]
      options.each {|name, value| send("#{name}=", value)}
    end

    # Build a new instance of this resource and
    # automatically calls the +save+ method.
    #
    def create(attributes = {})
      build(attributes).tap do |resource|
        resource.save
      end
    end

    # Retrive all items from this collection.
    #
    def all
      response = Codeplane::Request.get(resource_path)
      response.payload.collect do |attributes|
        build(attributes)
      end
    end

    # Implement the +each+ method required by Enumerable module.
    #
    def each(&block)
      all.each(&block)
    end

    # Build a new instance of this resource.
    #
    def build(attributes = {})
      resource_class.new(attributes.merge(:collection_resource_path => resource_path))
    end

    # Return the resource class based on
    # Codeplane::Collection#resource_class_name.
    #
    def resource_class
      Codeplane::Resource.const_get(resource_class_name)
    end
  end
end
