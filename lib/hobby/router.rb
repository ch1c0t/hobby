module Hobby
  class Router
    def initialize
      @routes = Routes.new
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
  end
end

require 'hobby/router/routes'
require 'hobby/router/route'
