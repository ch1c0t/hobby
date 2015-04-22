module Hobbit
  class Verb
    extend Forwardable

    def_delegators :@routes, :first, :last

    def initialize
      @routes = []
    end

    def <<(route)
      @routes << route
    end

    def route_for(request)
      route = @routes.detect do |r|
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
