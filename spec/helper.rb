require 'devtools/spec_helper'

require 'hobby'
require 'hobby/rspec/router'

require 'minitest'
require 'minitest-power_assert'
Minitest::Assertions.prepend Minitest::PowerAssert::Assertions

if defined? Mutant
  class Mutant::Selector::Expression
    def call _subject
      integration.all_tests
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec, :minitest
  config.include Hobby::RSpec::Router, type: :router
end
