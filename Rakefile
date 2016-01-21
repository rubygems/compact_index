require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w(--color)
  end

  begin
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new
  rescue LoadError
    task :rubocop
  end

  task :default => [:rubocop, :spec]
rescue LoadError => e
  # rspec won't exist on production
end
