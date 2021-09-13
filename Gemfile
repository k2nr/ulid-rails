source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in ulid-rails.gemspec
gemspec

version = ENV["AR_VERSION"] || "6.0"
eval_gemfile File.expand_path("../gemfiles/#{version}.gemfile", __FILE__)
