require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

ROOT = File.expand_path('../', __FILE__)

RuboCop::RakeTask.new

# Avoiding RSpec::Core::RakeTask.new
# because we want to run each spec individually. Slower startup time but it
# allows us to ensure there are no missing dependencies.
task :spec do
  Dir["#{ROOT}/spec/**/*_spec.rb"].each do |spec|
    unless system("bundle exec rspec -f d -bc #{spec}")
      exit 1
    end
  end
end
task default: [:lint, :spec]
task test: :spec
task lint: :rubocop
