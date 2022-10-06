# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files = %w[lib/**/*.rb - CHANGELOG.md]
  t.options = %w[--private -o ./docs]
end

require "standard/rake"

task default: %i[spec standard]
