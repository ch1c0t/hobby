class Hobby::Router
  class Route
    def initialize verb, path, &action
      @verb, @path, @action = verb, path, action
    end

    attr_reader :verb, :path
    attr_accessor :action

    alias to_proc action
  end
end
