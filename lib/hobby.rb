require 'rack'
require 'include_constants'
require 'forwardable'

module Hobby
  Verbs = %w!DELETE GET HEAD OPTIONS PATCH POST PUT!
  include_constants :Builder, :Request, :Response, from: Rack
end

require 'hobby/router'
require 'hobby/app'
