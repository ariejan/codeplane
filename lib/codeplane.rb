require "openssl"
require "net/https"
require "uri"
require "json"
require "time"
require "yaml"
require "tmpdir"
require "digest/sha1"
require "logger"

require "codeplane/core_ext"

require "active_support/core_ext/object/to_param"
require "active_support/core_ext/object/to_query"
require "active_support/inflector"
require "active_support/core_ext/string/strip"
require "active_support/core_ext/object/blank"

# A Ruby class to call the Codeplane REST API. You might use this if you want to
# manage your account from within a Ruby program.
#
# Example:
#
#   require "codeplane"
#
#   Codeplane.configure do |config|
#     config.username = "john"
#     config.api_key = "d02fdc830997aa66f95d"
#   end
#
#   codeplane = Codeplane::Client.new
#   codeplane.repositories.each do |repo|
#     puts repo.name
#   end
#
module Codeplane
  autoload :Client, "codeplane/client"
  autoload :CLI, "codeplane/cli"
  autoload :Collection, "codeplane/collection"
  autoload :Request, "codeplane/request"
  autoload :Response, "codeplane/response"
  autoload :Resource, "codeplane/resource"
  autoload :Version, "codeplane/version"

  class Codeplane::UnauthorizedError < StandardError; end
  class Codeplane::NotFoundError < StandardError; end
  class Codeplane::AbstractMethodError < StandardError; end
  class Codeplane::UnsavedResourceError < StandardError; end
  class Codeplane::OwnershipError < StandardError; end

  class << self
    # Set the username that will do requests to the API.
    # Will be send in every request.
    #
    attr_accessor :username

    # Set the API key that will do requests to the API.
    # Will be send in every request.
    #
    attr_accessor :api_key
  end

  # Return API's endpoint.
  # Can override real API by setting
  # +CODEPLANE_ENDPOINT+ environment variable.
  #
  def self.endpoint
    ENV.fetch("CODEPLANE_ENDPOINT", "https://codeplane.com/api/v1")
  end

  # Yield Codeplane module so you can easily configure options.
  #
  def self.configure(&block)
    yield Codeplane
  end
end
