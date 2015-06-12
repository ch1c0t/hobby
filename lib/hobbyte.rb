require 'rack'
require 'forwardable'

module Hobbyte
  require 'hobbyte/base'
  autoload :Builder,  'hobbyte/builder'
  autoload :Router,   'hobbyte/router'
  autoload :Request,  'hobbyte/request'
  autoload :Response, 'hobbyte/response'
end
