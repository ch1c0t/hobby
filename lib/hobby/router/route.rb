class Hobby::Router
  class Route
    attr_reader :compiled_path, :extra_params, :path
    def initialize(path, &block)
      @path  = path
      @block = block

      @extra_params = []
      compiled_path = path.gsub(/:\w+/) do |match|
        @extra_params << match.gsub(':', '').to_sym
        '([^/?#]+)'
      end
      @compiled_path = /^#{compiled_path}$/
    end

    def to_proc
      @block
    end
  end
end
