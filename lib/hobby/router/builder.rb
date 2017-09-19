module Hobby
  class Router
    class Builder < Rack::Builder
      # To work around
      # https://github.com/mbj/mutant#the-crash--stuck-problem-mri
      alias add_use use
      alias add_map2 map

      def add_map map
        if map.app
          add_map2 map.path do run map.app end
        else
          add_map2 map.path, &map.block
        end
      end

      class Map
        attr_reader :path, :app, :block
        def initialize path, app, &block
          @path, @app, @block = path, app, block
        end
      end
    end
  end
end
