require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Dir.chdir(File.expand_path('../', __FILE__))

Bundler::GemHelper.install_tasks

RuboCop::RakeTask.new(:lint)

RSpec::Core::RakeTask.new

task default: %w(lint spec)
