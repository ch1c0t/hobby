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
  end
end
