require 'rack'
require 'forwardable'

module Hobby
  VERBS = %w[DELETE GET HEAD OPTIONS PATCH POST PUT]
end

require 'hobby/router'
require 'hobby/app'
