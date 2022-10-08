# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

SUPPORTED_RUBY_VERSIONS = %w[2.7 3.0 3.1 3.2-rc]

desc "Run specs against all Ruby versions and platforms"
task "spec:all" do
  SUPPORTED_RUBY_VERSIONS.each do |version|
    project_tag = "inoculate:ruby-#{version}"
    sh "docker build --build-arg TAG=#{version} -t #{project_tag} ."
    sh "docker run --rm -ti -v $PWD:/app -w /app #{project_tag} bundle exec rake spec"
  end
end

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.before = -> { sh("rm -r ./docs") }
  t.files = %w[lib/**/*.rb - CHANGELOG.md]
  t.options = %w[-o ./docs]
end

require "standard/rake"

task default: %i[spec standard]
