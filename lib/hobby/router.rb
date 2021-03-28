module Hobby
  class Router
    def initialize
      @routes = Routes.new
      @uses, @maps = [], []
    end

    def initialize_copy _router
      @uses, @maps = @uses.dup, @maps.dup
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

    def map path, app
      @maps << [path, app]
    end

    attr_accessor :app

    def to_rack_app
      builder = create_builder
      builder.run app
      builder.to_app
    end

    private
      def create_builder
        builder = Rack::Builder.new

        @uses.each { |all| builder.use *all }
        @maps.each { |path, app|
          builder.map path do run app end
        }

        builder
      end
  end
end

require 'hobby/router/routes'
require 'hobby/router/route'
