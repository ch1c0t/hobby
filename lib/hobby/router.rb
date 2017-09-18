module Hobby
  class Router
    def initialize
      @routes = Routes.new
      @uses, @maps = [], []
    end

    def add_route verb, path, &action
      route = Route.new verb, path, &action

      path = nil if path.eql? '/'
      @routes["#{verb}#{path}"] = route

      route
    end

    def route_for env
      route, params = @routes["#{env['REQUEST_METHOD']}#{env['PATH_INFO']}"]
      params ? route.with_params(params) : route
    end

    def use *all
      @uses << all
    end

    def map path, &block
      @maps << [path, block]
    end

    # Hobby application.
    attr_accessor :app

    # Create a Rack application.
    def to_app
      builder = Rack::Builder.new
      fill_builder builder
      builder.run app
      builder.to_app
    end

    private
      def fill_builder builder
        @uses.each { |all| builder.use *all }
        @maps.each { |path, block| builder.map path, &block }
      end
  end
end

require 'hobby/router/routes'
require 'hobby/router/route'
