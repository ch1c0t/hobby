module Hobbyte
  class Base
    class << self
      def members
        @members ||= {}
      end

      [:builder, :router, :request, :response].each do |member|
        define_method member do |&custom_member|
          if custom_member
            members[member] = custom_member.call
          else
            members[member] ||= Hobbyte.const_get(member.capitalize).call
          end
        end
      end

      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method verb.downcase do |path, &route|
          router.add_route verb, path, &route
        end
      end

      alias :_new :new
      def new(*args, &block)
        builder.run _new(*args, &block)
        builder
      end

      extend Forwardable
      delegate [:map, :use] => :builder

      def call(env)
        new.call env
      end
    end

    attr_reader :env, :request, :response

    def call(env)
      dup._call env
    end

    def _call(env)
      @env      = env
      @request  = self.class.request.new @env
      @response = self.class.response.new

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
