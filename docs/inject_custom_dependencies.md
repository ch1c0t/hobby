You can inject custom dependencies into your apps as follows:

```ruby
class Router < Hobby::Router
end

class Request < Rack::Request
end

class Response < Rack::Response
end

class App
  include Hobby

  self.router   = Router.new
  self.request  = Rack::Request
  self.response = Rack::Response
end
```
