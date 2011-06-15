require "bundler"
Bundler.setup(:default, :development)
Bundler.require(:default, :development)

require "codeplane"
require "test_notifier/runner/rspec"
require "base64"
require "addressable/uri"

FakeWeb.allow_net_connect = false

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|file| require file}

RSpec.configure do |config|
  config.include Helpers

  config.before do
    ENV.delete("CODEPLANE_ENDPOINT")

    config_file = "/tmp/codeplane_config"
    File.unlink(config_file) if File.exist?(config_file)

    Codeplane.configure do |config|
      config.username = nil
      config.api_key = nil
    end
  end
end
