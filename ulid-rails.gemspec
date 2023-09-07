lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ulid/rails/version"

Gem::Specification.new do |spec|
  spec.name = "ulid-rails"
  spec.version = ULID::Rails::VERSION
  spec.required_ruby_version = ">= 2.5.0"
  spec.authors = ["Kazunori Kajihiro", "Zendesk"]
  spec.email = ["kazunori.kajihiro@gmail.com", "ruby-core@zendesk.com"]

  spec.summary = "ULID for Rails"
  spec.description = "ULID for Rails"
  spec.homepage = "https://github.com/k2nr/ulid-rails/"
  spec.license = "MIT"

  spec.metadata = {
    "changelog_uri" => "https://github.com/k2nr/ulid-rails/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/k2nr/ulid-rails/",
    "bug_tracker_uri" => "https://github.com/k2nr/ulid-rails/issues",
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = %w[
    CHANGELOG.md
    LICENSE.txt
    README.md
    lib/ulid/rails.rb
    lib/ulid/rails/errors.rb
    lib/ulid/rails/patch.rb
    lib/ulid/rails/postgresql_type.rb
    lib/ulid/rails/sqlite_type.rb
    lib/ulid/rails/type.rb
    lib/ulid/rails/version.rb
    ulid-rails.gemspec
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "ulid", "~> 1.0"
  spec.add_dependency "base32-crockford", "~> 0.1"
  spec.add_dependency "activesupport", ">= 5.2"
  spec.add_dependency "activemodel", ">= 5.2"
  spec.add_dependency "activerecord", ">= 5.2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "standard", "~> 1.16.0"
end
