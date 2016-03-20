require 'devtools/spec_helper'

require 'hobby'
require 'hobby/rspec/router'

RSpec.configure do |config|
  config.include Hobby::RSpec::Router, type: :router
end

require 'rspec-power_assert'
RSpec::PowerAssert.example_assertion_alias :assert
RSpec::PowerAssert.example_group_assertion_alias :assert
