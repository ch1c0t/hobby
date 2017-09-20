require 'json'

app = Class.new do
  include Hobby
  get { 'hello world'.to_json }

  use Rack::ContentType, 'application/html'

  def initialize middleware_with_arguments = nil
    use *middleware_with_arguments if middleware_with_arguments
  end
end

map '/1', app.new
map '/2', app.new([Rack::ContentType, 'application/json'])
map '/3', app.new
