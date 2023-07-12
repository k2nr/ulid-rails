lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ulid/rails/version"

Gem::Specification.new do |spec|
  spec.name = "ulid-rails"
  spec.version = ULID::Rails::VERSION
  spec.required_ruby_version = ">= 2.5.0"
  spec.authors = ["Kazunori Kajihiro", "Zendesk"]
  spec.email = ["kazunori.kajihiro@gmail.com", "ruby-core@zendesk.com"]

  spec.summary = "ULID for rails"
  spec.description = "ULID for rails"
  spec.homepage = "https://github.com/k2nr/ulid-rails/"
  spec.license = "MIT"

  spec.metadata = {
    "changelog_uri" => "https://github.com/k2nr/ulid-rails/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/k2nr/ulid-rails/",
    "bug_tracker_uri" => "https://github.com/k2nr/ulid-rails/issues",
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ulid", "~> 1.0"
  spec.add_dependency "base32-crockford", "~> 0.1"
  spec.add_dependency "activesupport", ">= 5.0"
  spec.add_dependency "activemodel", ">= 5.0"
  spec.add_dependency "activerecord", ">= 5.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "standard", "~> 1.16.0"
end
