# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'hobby'
  spec.version       = '0.2.0'
  spec.authors       = ['Anatoly Chernow']
  spec.email         = ['chertoly@gmail.com']
  spec.summary       = %q{A professional way to create Rack applications.}
  spec.homepage      = 'https://github.com/ch1c0t/hobby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rack', '>= 2'

  spec.required_ruby_version = '>= 2.6.6'
end
