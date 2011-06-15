module Codeplane
  class Response
    attr_accessor :raw

    def initialize(raw = nil)
      @raw = raw
    end

    def status
      raw.code.to_i
    end

    def success?
      raw.code =~ /^2/
    end

    def redirect?
      raw.code =~ /^3/
    end

    def error?
      raw.code =~ /^5/
    end

    def payload
      JSON.load raw.body
    end
  end
end
