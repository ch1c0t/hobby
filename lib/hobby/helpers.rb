module Hobby
  module Helpers
    attr_reader :env, :route

    def router
      @router ||= begin
                    router = self.class.router.clone
                    router.app = self
                    router
                  end
    end

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

    def status status
      response.status = status
    end
  end
end
