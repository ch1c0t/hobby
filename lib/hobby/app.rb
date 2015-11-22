module Hobby
  module App
    def self.included app
      app.extend Singleton
      app.builder, app.router = Builder.new, Router.new
      app.request, app.response = Request, Response
    end

    module Singleton
      attr_accessor :builder, :router, :request, :response

      def new (*)
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

    def call env
      dup.handle env
    end

    protected
      def handle env
        @env = env

        route = self.class.router.route_for request

        if route
          response.write instance_eval &route
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
  end
end
