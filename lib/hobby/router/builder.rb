module Hobby
  class Router
    class Builder < Rack::Builder
      # To work around
      # https://github.com/mbj/mutant#the-crash--stuck-problem-mri
      alias add_use use
      alias add_map map
    end
  end
end
