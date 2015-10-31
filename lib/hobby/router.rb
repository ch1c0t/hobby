module Hobby
  class Router
    require_relative 'router/pattern'

    def initialize
      @patterns = Hash.new { |hash, key| hash[key] = [] }

      @routes = -> verb do
        -> path do
          pair = nil
          @patterns[verb].find { |pattern| pair = pattern[path] }
          pair
        end
      end
    end

    def add_route verb, path = '/', &route
      @patterns[verb] << Pattern.new(path, route)
      self
    end

    def route_for request
      verb, path = request.request_method, (request.path_info.empty? ? '/' : request.path_info)
      route, params = @routes[verb][path]
      request.params.merge! params if params
      route
    end
  end
end
