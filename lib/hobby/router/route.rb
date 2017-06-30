class Hobby::Router
  class Route
    def initialize verb, path, &action
      @verb, @path, @action = verb, path, action
      @params = {}
    end

    attr_reader :verb, :path
    attr_accessor :action, :params

    def with_params params
      new_route = dup
      new_route.params = params
      new_route
    end

    alias to_proc action
  end
end
