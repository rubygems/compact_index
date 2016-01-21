source "https://rubygems.org"

# Specify your gem's dependencies in compact_index.gemspec
gemspec

group :documentation do
  gem "yard", "~> 0.8"
  gem "redcarpet", "~> 2.3"
end

group :development do
  gem "rubocop", :install_if => lambda { RUBY_VERSION >= "1.9" }
end
