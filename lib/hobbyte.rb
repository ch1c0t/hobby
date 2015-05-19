require 'rack'
require 'forwardable'

module Hobbyte
  autoload :Base,     'hobbyte/base'
  autoload :Builder,  'hobbyte/builder'
  autoload :Router,   'hobbyte/router'
  autoload :Request,  'hobbyte/request'
  autoload :Response, 'hobbyte/response'
end
