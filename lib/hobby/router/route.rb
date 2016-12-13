class Hobby::Router
  class Route
    attr_reader :verb, :path
    def initialize verb, path, &action
      @verb, @path, @action = verb, path, action
    end

    def to_proc
      @action
    end
  end
end
