# frozen_string_literal: true

require_relative "lib/inoculate/version"

Gem::Specification.new do |spec|
	spec.name = "inoculate"
	spec.version = Inoculate::VERSION
	spec.authors = ["Stephan Tarulli"]
	spec.email = ["srt@tinychameleon.com"]

	spec.summary = "A modest, concurrent dependency injection library"
	spec.description = <<~DESC
		Inoculate is a small, thread-safe dependency injection library configured entirely with Ruby.
		It provides several life-cycles and provides dependency access through private accessors.
	DESC
	spec.homepage = "https://github.com/tinychameleon/inoculate"
	spec.license = "MIT"
	spec.required_ruby_version = ">= 3.0"

	spec.metadata["rubygems_mfa_required"] = "true"

	spec.metadata["homepage_uri"] = spec.homepage
	spec.metadata["source_code_uri"] = "https://github.com/tinychameleon/inoculate"
	spec.metadata["bug_tracker_uri"] = "https://github.com/tinychameleon/inoculate/issues"
	spec.metadata["changelog_uri"] = "https://github.com/tinychameleon/inoculate/blob/main/CHANGELOG.md"
	spec.metadata["documentation_uri"] = "https://tinychameleon.github.io/inoculate"

	spec.files = Dir["lib/**/*.rb", "sig/**/*.rbs", "inoculate.gemspec", "CHANGELOG.md", "README.md", "LICENSE.txt"]
	spec.bindir = "exe"
	spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]

	# Uncomment to register a new dependency of your gem
	# spec.add_dependency "example-gem", "~> 1.0"

	# For more information and examples about making a new gem, check out our
	# guide at: https://bundler.io/guides/creating_gem.html
end
