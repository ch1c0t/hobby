module Hobbit
  autoload :Router, 'hobbit/router'

  class Base
    class << self
      extend Forwardable
      delegate [:map, :use] => :stack

      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method verb.downcase do |path, &route|
          router.add_route verb, path, &route
        end
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
      @env      = env
      @request  = Request.new @env
      @response = Response.new

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
