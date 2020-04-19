# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in compact_index.gemspec
gemspec

group :documentation do
  gem "redcarpet", "~> 2.3"
  gem "yard", "~> 0.9"
end

group :development do
  gem "rubocop", "~> 0.46.0", :install_if => lambda { RUBY_VERSION >= "2.0" }
end
