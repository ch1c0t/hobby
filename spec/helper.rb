require 'hobby'
require_relative 'mutant_patches' if defined? Mutant

require 'minitest'
require 'minitest-power_assert'
Minitest::Assertions.prepend Minitest::PowerAssert::Assertions

module EnvFor
  def env_for path, verb = 'GET'
    {'REQUEST_METHOD' => verb, 'PATH_INFO' => path }
  end
end

RSpec.configure do |config|
  config.expect_with :rspec, :minitest
  config.include EnvFor
end
