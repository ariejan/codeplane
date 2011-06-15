module Codeplane
  module Request
    HTTP_METHODS = [:Get, :Post, :Put, :Delete] # :nodoc:
    CA_FILE = File.dirname(__FILE__) + "/cacert.pem" # :nodoc:

    extend self

    # Do a HTTP request, wrapping all the logic
    # (basic auth credentials, endpoint, etc).
    #
    # This method has multiple shortcuts so you don't have to provide the
    # method name every time.
    #
    #   Codeplane::Request.request(:GET, "/repositories")
    #   Codeplane::Request.request(:POST, "/repositories", :name => "my-repo")
    #   Codeplane::Request.get("/repositories")
    #   Codeplane::Request.post("/repositories", :name => "my-repo")
    #   Codeplane::Request.put("/repositories/1", :name => "my-updated-repo")
    #   Codeplane::Request.delete("/repositories/1")
    #
    def request(method, path, params = nil)
      uri = URI.parse(url_for(path))

      client = Net::HTTP.new(uri.host, uri.port)
      client.use_ssl = uri.kind_of?(URI::HTTPS)
      client.verify_mode = OpenSSL::SSL::VERIFY_PEER
      client.ca_file = CA_FILE

      request = net_class(method).new(uri.request_uri)
      request.basic_auth Codeplane.username, Codeplane.api_key
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request["User-Agent"] = "Codeplane/#{Codeplane::Version::STRING}"
      request.body = params.to_param if request.request_body_permitted? && params

      response = client.request(request)

      case response.code
      when "401"
        raise Codeplane::UnauthorizedError, "Double check you username and API key"
      when "404"
        raise Codeplane::NotFoundError
      else
        Codeplane::Response.new(response)
      end
    end

    HTTP_METHODS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{method.to_s.downcase}(*args)          # def get(*args)
          request(:#{method}, *args)                #   request(:Get, *args)
        end                                         # end
      RUBY
    end

    # Return the correct Net class for the HTTP method.
    #
    def net_class(method) # :nodoc:
      Net::HTTP.const_get(method)
    end

    #
    #
    def url_for(path)
      File.join(Codeplane.endpoint, path)
    end
  end
end
