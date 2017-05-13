# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'applocale/version'

Gem::Specification.new do |spec|
  spec.name          = "applocale"
  spec.version       = Applocale::VERSION
  spec.authors       = ["Kennix Chui"]
  spec.email         = ["kennixdev@gmail.com"]

  spec.summary       = %q{for mobile application to manage locale}
  spec.description   = %q{It can convert file between string and xlsx, also support download xlsx from google}
  spec.homepage      = "https://github.com/kennix426/applocale"
  spec.license  = "MIT"
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

#  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files         = Dir['lib/*'] + Dir['exe/*'] + Dir['lib/**/*'] + Dir['lib/applocale/AppLocaleFile.yaml']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "activesupport", "~> 5.1"
  spec.add_dependency "thor", "~> 0.19.4"
  spec.add_dependency "google-api-client", "~> 0.11.1"
  spec.add_dependency "google_drive", '~> 2.1', '>= 2.1.3'
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "rubyXL", '~> 3.3', '>= 3.3.23'
end
