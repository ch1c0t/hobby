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

    def map path, to:
      @maps << [path, to]
    end

    attr_accessor :app

    def to_rack_app
      builder = Rack::Builder.new
      fill_builder builder
      builder.run app
      builder.to_app
    end

    private
      def fill_builder builder
        fill_with_uses builder
        fill_with_maps builder
      end

      def fill_with_uses builder
        @uses.each { |all| builder.use *all }
      end

      def fill_with_maps builder
        @maps.each { |path, app|
          builder.map path do run app end
        }
      end
  end
end

require 'hobby/router/routes'
require 'hobby/router/route'
