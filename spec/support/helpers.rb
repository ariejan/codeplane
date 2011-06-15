module Helpers
  def fixtures
    @fixtures ||= Pathname.new("spec/fixtures")
  end

  def default_credentials!
    Codeplane.configure do |config|
      config.username = "john"
      config.api_key = "abc"
    end
  end

  def request_body
    Addressable::URI.parse("?#{FakeWeb.last_request.body}").query_values
  end

  def clean(string)
    string.gsub(/\e\[\d+m/, "")
  end
end