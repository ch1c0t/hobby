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
        @route = self.class.router.route_for (@env = env)

        body = route ? (instance_exec &route) : not_found
        response.write body

        response
      end
    end

  private
    attr_reader :env, :route

    def request
      @request ||= self.class.request.new env
    end

    def response
      @response ||= self.class.response.new
    end

    def my
      route.params
    end

    def halt
      throw :halt, response
    end

    def not_found
      response.status = 404
    end

    def content_type type
      mime_type = Rack::Mime::MIME_TYPES.fetch ".#{type}"
      response.add_header 'Content-Type', mime_type
    end
end
