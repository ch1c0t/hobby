module Hobby
  module App
    def self.included app
      app.extend Singleton
      app.builder, app.router = Rack::Builder.new, Router.new
      app.request, app.response = Rack::Request, Rack::Response
    end

    module Singleton
      attr_accessor :builder, :router, :request, :response

      def new (*)
        builder.run super
        builder.to_app
      end

      extend Forwardable
      delegate [:map, :use] => :builder

      VERBS.each do |verb|
        define_method verb.downcase do |path = '/', &route|
          router.add_route verb, path, &route
        end
      end
    end

    def call env
      dup.handle env
    end

    protected
      def handle env
        route = self.class.router.route_for (@env = env)

        if route
          response.write instance_exec &route
        else
          response.status = 404
        end

        response
      end

    private
      attr_reader :env

      def request
        @request ||= self.class.request.new env
      end

      def response
        @response ||= self.class.response.new
      end

      def my
        env.fetch :path_params, {}
      end
  end
end
