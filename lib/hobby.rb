require 'rack'
require 'forwardable'

require 'hobby/router'

module Hobby
  App = Hobby # to stay compatible with old code
  VERBS = %w[DELETE GET HEAD OPTIONS PATCH POST PUT]

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
      define_method verb.downcase do |path = '/', &action|
        router.add_route verb, path, &action
      end
    end
  end

  def call env
    dup.handle env
  end

  protected
    def handle env
      catch :halt do
        route = self.class.router.route_for (@env = env)

        if route
          response.write instance_exec &route
        else
          response.status = 404
        end

        response
      end
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

    def halt
      throw :halt, response
    end
end
