module Hobby
  class App
    class << self
      def members
        @members ||= {}
      end

      [:builder, :router].each do |member|
        define_method member do |&custom_member|
          if custom_member
            members[member] = custom_member.call
          else
            members[member] ||= Hobby.const_get(member.capitalize).new
          end
        end
      end

      Verbs.each do |verb|
        define_method verb.downcase do |path, &route|
          router.add_route verb, path, &route
        end
      end

      alias :_new :new
      def new *args, &block
        builder.run _new(*args, &block)
        builder
      end

      extend Forwardable
      delegate [:map, :use] => :builder
    end

    attr_reader :env, :request, :response

    def call env
      dup.handle env
    end

    def handle env
      @env      = env
      @request  = Request.new @env
      @response = Response.new

      catch(:halt) { route_eval }
    end

    private

    def halt response
      throw :halt, response
    end

    def route_eval
      route = self.class.router.route_for request

      if route
        response.write instance_eval &route
      else
        response.status = 404
      end

      response.finish
    end
  end
end
