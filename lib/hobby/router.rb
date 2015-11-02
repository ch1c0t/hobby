module Hobby
  class Router
    def initialize
      @routes = Routes.new
    end

    def add_route verb, path = '/', &route
      @routes["#{verb}#{path}"] = route
      self
    end

    def route_for request
      route, params = @routes["#{request.request_method}#{request.path_info}"]
      request.params.merge! params if params
      route
    end

    class Routes < Hash
      def initialize
        @patterns = {}
        super { |hash, key| hash[key] = find key }
      end

      def []= key, route
        if key.include? ?:
          @patterns[/^#{key.gsub(/(:\w+)/){"(?<#{$1[1..-1]}>[^/?#]+)"}}$/] = route
        else
          super
        end
      end

      private

      def find key
        _, route = @patterns.find { |pattern, _| pattern.match key }
        route ? [route, $~.names.map(&:to_sym).zip($~.captures).to_h] : nil
      end
    end
  end
end
