module Hobby::RSpec
  module Router
    extend self
    SOME_ROUTE = ->{:some_route}

    def env_for path, verb = 'GET'
      {'REQUEST_METHOD' => verb, 'PATH_INFO' => path }
    end

    def add_routes *routes
      routes.each { |route| subject.add_route 'GET', route, &SOME_ROUTE }
    end

    extend RSpec::Matchers::DSL
    
    define :find_route do |path, verb = 'GET'|
      match do |subject|
        env = env_for path, verb
        route = subject.route_for env

        params_are_ok = (@params ? (@params.to_a - env[:path_params].to_a).empty? : true)

        route && (route.to_proc.call == SOME_ROUTE.call) && params_are_ok
      end

      chain :and_set_params do |**params|
        @params = params
      end
    end

    def self.included example_group
      example_group.extend self
    end
  end
end
