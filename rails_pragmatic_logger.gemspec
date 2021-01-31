require_relative 'lib/rails_pragmatic_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_pragmatic_logger"
  spec.version       = RailsPragmaticLogger::VERSION
  spec.authors       = ["Pablo Vizcay"]
  spec.email         = ["pablo.vizcay@gmail.com"]

  spec.summary       = %q{Rails pragmatic logger}
  spec.description   = %q{Opinionated logger that outputs JSON}
  spec.homepage      = "https://github.com/vizcay/rails_pragmatic_logger"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vizcay/rails_pragmatic_logger"
  spec.metadata["changelog_uri"] = "https://github.com/vizcay/rails_pragmatic_logger/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
