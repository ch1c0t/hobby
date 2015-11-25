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
      verb, path = request.request_method, request.path_info
      route, params = @routes["#{verb}#{path.empty? ? '/' : path}"]
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
          string = key.gsub(/(:\w+)/) { "(?<#{$1[1..-1]}>[^/?#]+)" }
          @patterns[/^#{string}$/] = route
        else
          super
          super "#{key}/", route unless key.end_with? '/'
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
