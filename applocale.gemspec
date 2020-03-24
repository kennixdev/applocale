# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'applocale/version'

Gem::Specification.new do |spec|
  spec.name          = "applocale"
  spec.version       = Applocale::VERSION
  spec.authors       = ["Kennix"]
  spec.email         = ["kennixdev@gmail.com", "johnwongapi@gmail.com"]

  spec.summary       = %q{for mobile application to manage localization}
  spec.description   = %q{Applocale is a localization tool, It can convert file between string and xlsx ,csv, also support download xlsx or csv from google. You can also setup conversion logic for string value of each project. Support ios, android and json format.}
  spec.homepage      = "https://github.com/kennixdev/applocale"
  spec.license  = "MIT"
  spec.required_ruby_version = '>= 2.3.1'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

#  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files         = Dir['lib/*'] + Dir['exe/*'] + Dir['lib/**/*'] + Dir['lib/applocale/AppLocaleFile.yaml']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "thor", "~> 0.19.4"
  spec.add_dependency "google-api-client", '~> 0.11'
  # spec.add_dependency "google_drive", '~> 2.0'
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "rubyXL", '~> 3.3', '>= 3.3.23'
  spec.add_dependency "parallel", '1.11.2'
end
