require 'rack'
require 'forwardable'
require 'include_constants'

module Hobby
  Verbs = %w!DELETE GET HEAD OPTIONS PATCH POST PUT!
  require 'hobby/app'
  autoload :Router, 'hobby/router'
  autoload :Middleware, 'hobby/middleware'
  include_constants :Builder, :Request, :Response, from: Rack
end
