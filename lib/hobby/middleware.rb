module Hobby
  class Middleware
    def initialize app, *a, &b
      @app = app
      args *a, &b if respond_to? :args
      self
    end

    def call env
      @env = env
      before if respond_to? :before
      @status, @header, @body = @app.call @env
      after if respond_to? :after
      @status, @header, @body = @response.finish if @response
      [@status, @header, @body]
    end


    def header
      @header = Rack::Utils::HeaderHash.new @header
    end

    def request
      @request ||= Request.new @env
    end

    def response
      @response ||= Response.new @body, @status, @header
    end
  end
end
