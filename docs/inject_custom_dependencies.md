You can inject custom dependencies into your apps as follows:

```ruby
class CustomRouter < Hobby::Router
end

class CustomRequest < Rack::Request
end

class CustomResponse < Rack::Response
end

class App
  include Hobby

  self.router   = CustomRouter.new
  self.request  = CustomRequest
  self.response = CustomResponse
end
```
