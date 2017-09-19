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

    def map path, app = nil, &block
      @maps << Builder::Map.new(path, app, &block)
    end

    attr_accessor :app

    def to_rack_app
      builder = create_builder
      builder.run app
      builder.to_app
    end

    private
      def create_builder
        builder = Builder.new
        @uses.each { |all| builder.add_use *all }
        @maps.each { |map| builder.add_map map }
        builder
      end
  end
end

require 'hobby/router/builder'
require 'hobby/router/routes'
require 'hobby/router/route'
