require 'json'

get { 'hello world'.to_json }

def initialize
  use Rack::ContentType, 'application/json'
end
