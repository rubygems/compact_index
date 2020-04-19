# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in compact_index.gemspec
gemspec

group :documentation do
  gem "redcarpet", "~> 2.3"
  gem "yard", "~> 0.9"
end

group :development do
  gem "rubocop", :install_if => lambda { RUBY_VERSION >= "2.0" }
end
