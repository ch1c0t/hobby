module Hobby
  class App
    def self.inherited subclass
      subclass.const_set :Router, Router.new
      subclass.const_set :Builder, Builder.new

      class << subclass
        Verbs.each do |verb|
          define_method verb.downcase do |path, &route|
            self::Router.add_route verb, path, &route
          end
        end

        alias_method :_new, :new
        def new *args, &block
          self::Builder.run _new *args, &block
          self::Builder.to_app
        end

        def method_missing method, *args, &block
          self::Builder.send method, *args, &block if [:map, :use].include? method
        end
      end
    end

    attr_reader :env, :request, :response

    def call env
      dup.handle env
    end

    def handle env
      @env      = env
      @request  = Request.new @env
      @response = Response.new

      route = self.class::Router.route_for request

      if route
        response.write instance_eval &route
      else
        response.status = 404
      end

      response.finish
    end
  end
end
