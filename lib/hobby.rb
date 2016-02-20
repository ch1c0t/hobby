require 'rack'
require 'forwardable'

module Hobby
  Verbs = %w!DELETE GET HEAD OPTIONS PATCH POST PUT!
end

require 'hobby/router'
require 'hobby/app'
