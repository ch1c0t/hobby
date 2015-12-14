module Hobby
  class Router
    def initialize
      @routes = Routes.new
    end

    def add_route verb, path = nil, &route
      @routes["#{verb}#{path}"] = route
    end

    def route_for env
      route, params = @routes[env.values_at('REQUEST_METHOD', 'PATH_INFO').join]
      env[:path_params] = params if params
      route
    end

    class Routes < Hash
      def initialize
        @patterns = {}
        super { |hash, key| hash[key] = find key }
      end

      def []= key, route
        if key.include? ?:
          string = key.gsub(/(:\w+)/) { "(?<#{$1[1..-1]}>[^/?#]+)" }
          @patterns[/^#{string}$/] = route
        else
          super and super "#{key}/", route
        end
      end

      private

      def find key
        _, route = @patterns.find { |pattern, _| pattern.match key }
        [route, $~.names.map(&:to_sym).zip($~.captures).to_h] if route
      end
    end
  end
end
