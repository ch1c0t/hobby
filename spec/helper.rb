require 'devtools/spec_helper'

require 'hobby'

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
end
