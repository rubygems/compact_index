# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in compact_index.gemspec
gemspec

group :documentation, :optional => true do
  gem "redcarpet", "~> 3.5"
  gem "yard", "~> 0.9"
end

group :development do
  gem "rubocop", "~> 1.50.2"
  gem "rubocop-performance", :require => false
end

group :conformance, :optional => true do
  gem "rackup"
  gem "sinatra"
end

gem "minitest"
