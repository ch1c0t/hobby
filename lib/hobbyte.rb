require 'rack'
require 'forwardable'

module Hobbyte
  autoload :Router, 'hobbyte/router'

  require 'hobbyte/base'
  require 'hobbyte/builder'
  require 'hobbyte/request'
  require 'hobbyte/response'
end
