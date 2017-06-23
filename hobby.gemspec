# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'hobby'
  spec.version       = '0.0.10'
  spec.authors       = ['Anatoly Chernow']
  spec.email         = ['chertoly@gmail.com']
  spec.summary       = %q{A minimal DSL over rack}
  spec.homepage      = 'https://github.com/ch1c0t/hobby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rack'
end
