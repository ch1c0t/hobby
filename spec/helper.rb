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

  class Mutant::Isolation::Fork
    def result
      yield
    end
  end

  class Mutant::Loader
    def call
      source = Unparser.unparse node

      puts <<~S
        Current mutantion:
        #{source}
      S

      kernel.eval source, binding, subject.source_path.to_s, subject.source_line
    end
  end
end

module EnvFor
  def env_for path, verb = 'GET'
    {'REQUEST_METHOD' => verb, 'PATH_INFO' => path }
  end
end

RSpec.configure do |config|
  config.expect_with :rspec, :minitest
  config.include EnvFor
end
