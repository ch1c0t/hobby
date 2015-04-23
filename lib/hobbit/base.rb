module Hobbit
  class Base
    class << self
      extend Forwardable

      def_delegators :stack, :map, :use

      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) { |path, &block| router.add_route(verb, path, &block) }
      end

      alias :_new :new
      def new(*args, &block)
        stack.run _new(*args, &block)
        stack
      end

      def call(env)
        new.call env
      end

      def router
        if block_given?
          @router = yield
        else
          @router ||= Router.new
        end
      end

      def stack
        @stack ||= Rack::Builder.new
      end
    end

    attr_reader :env, :request, :response

    def call(env)
      dup._call env
    end

    def _call(env)
      @env = env
      @request = Hobbit::Request.new @env
      @response = Hobbit::Response.new
      catch(:halt) { route_eval }
    end

    def halt(response)
      throw :halt, response
    end

    private

    def route_eval
      route = self.class.router.route_for(request)

      if route
        response.write instance_eval(&route)
      else
        response.status = 404
      end

      response.finish
    end
  end
end
