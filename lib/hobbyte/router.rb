module Hobbyte
  class Router
    require_relative 'router/route'

    def initialize
      @routes = Hash.new { |hash, key| hash[key] = [] }
    end

    def add_route(verb, path, &block)
      @routes[verb] << Route.new(path, &block)
    end

    def route_for(request)
      route = @routes[request.request_method].detect do |r|
        r.compiled_path =~ request.path_info
      end

      if route
        $~.captures.each_with_index do |value, index|
          param = route.extra_params[index]
          request.params[param] = value
        end
      end

      route
    end
  end
end
