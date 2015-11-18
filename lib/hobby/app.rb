module Hobby
  module App
    def self.included app
      app.extend Singleton
      app.builder, app.router = Builder.new, Router.new
    end

    module Singleton
      attr_accessor :builder, :router

      def new *args, &block
        builder.run super
        builder.to_app
      end

      extend Forwardable
      delegate [:map, :use] => :builder

      Verbs.each do |verb|
        define_method verb.downcase do |path = nil, &route|
          router.add_route verb, *path, &route
        end
      end
    end

    attr_reader :env, :request, :response

    def call env
      dup.handle env
    end

    def handle env
      @env      = env
      @request  = Request.new env
      @response = Response.new

      route = self.class.router.route_for request

      if route
        response.write instance_eval &route
      else
        response.status = 404
      end

      response
    end
  end
end
