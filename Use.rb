require 'hobby'

class App
  include Hobby

  middleware = Class.new do
    def initialize(app = nil)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      @app.call(env) unless request.path_info == '/use'
      [200, {}, 'from use']
    end
  end

  use middleware

  get('/') { 'hello world' }
end
