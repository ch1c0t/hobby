require 'hobbyte'
require 'rack/test'

require 'minitest-power_assert'
require 'minitest/autorun'

def scope(name, &block)
  describe(name, &block)
end

module Minitest
  class Test
    include Rack::Test::Methods

    def mock_app(&block)
      @app = Class.new(Hobbyte::Base, &block).new
    end

    def app
      @app
    end

    def request_to path, request_method: 'GET'
      Hobbyte::Request.call.new Rack::MockRequest.env_for "http://example.com:8080/#{path}", method: request_method
    end
  end
end
