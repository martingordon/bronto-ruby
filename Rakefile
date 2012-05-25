#!/usr/bin/env rake
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "bundler/gem_tasks"
require "rake/testtask"
require "./lib/bronto"

Rake::TestTask.new(:test) do |test|
  test.ruby_opts = ["-rubygems"] if defined? Gem
  test.libs << "lib" << "test"
  test.pattern = "test/**/*_test.rb"
end
