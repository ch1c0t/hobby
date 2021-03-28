require 'rack'
require 'forwardable'

require 'hobby/router'
require 'hobby/helpers'

module Hobby
  VERBS = %w[DELETE GET HEAD OPTIONS PATCH POST PUT]

  def self.included app
    app.extend Singleton
    app.router = Router.new
    app.request, app.response = Rack::Request, Rack::Response
  end

  module Singleton
    attr_accessor :router, :request, :response

    def new (*)
      super.router.to_rack_app
    end

    extend Forwardable
    delegate [:map, :use] => :router

    VERBS.each do |verb|
      define_method verb.downcase do |path = '/', &action|
        router.add_route verb, path, &action
      end
    end
  end

  include Helpers

  def call env
    dup.handle env
  end

  protected
    def handle env
      catch :halt do
        @route = router.route_for (@env = env)
        fill_body
        response.to_a
      end
    end

  private
    def fill_body
      body = route ? (instance_exec &route) : not_found
      response.write body
    end
end
