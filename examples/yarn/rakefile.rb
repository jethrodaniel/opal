# frozen_string_literal: true

require 'rake/clean'
require 'rake/testtask'

task :default => :build

desc 'run the app (cleans and builds first)'
task :run => [:clean, :build] do
  sh 'node build/app.js'
end

desc 'builds .js files from .rb files'
task :build => 'lib/app.js'

file 'lib/app.js' do
  sh 'opal --compile --no-opal lib/app.rb > build/app.js'
end

CLEAN << FileList['build/**/*']
