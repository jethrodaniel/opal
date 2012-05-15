require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'

HEADER = <<-EOS
/*!
 * Opal v#{Opal::VERSION}
 * http://opalrb.org
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT License
 */
 EOS

Opal::BuilderTask.new do |t|
  t.name  = 'opal'
  t.files = []
  t.dependencies = %w[opal-spec opal-racc opal-strscan]
end

def write(path, str)
  File.open(path, 'w+') { |o| o.puts str }
end

task :build_directory do
  FileUtils.mkdir_p 'build'
end

desc "Build opal.js into build/"
task :opal => :build_directory do
  code   = []
  core   = File.read('core/load_order').strip.split.map do |c|
    File.read "core/#{c}.rb"
  end

  browser = File.read('browser/load_order').strip.split.map do |b|
    File.read "browser/#{b}.rb"
  end

  methods = Opal::Parser::METHOD_NAMES.map { |f, t| "'#{f}': '$#{t}$'"}
  runtime = File.read 'core/runtime.js'
  corelib = Opal.parse (core + browser).join("\n")

  File.open('build/opal.js', 'w+') do |o|
    o.puts <<-EOS
#{HEADER}
(function(undefined) {
#{runtime}
var method_names = {#{ methods.join ', ' }}, reverse_method_names = {};
for (var id in method_names) {
  reverse_method_names[method_names[id]] = id;
}
#{corelib}
}).call(this);
  EOS
end
end

desc "Check file sizes for core builds"
task :sizes do
  sizes 'build/opal.js'
end

desc "Rebuild grammar.rb for opal parser"
task :racc do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

##
# Rubygems
#

namespace :gem do
  desc "Build opal-#{Opal::VERSION}.gem"
  task :build do
    sh "gem build opal.gemspec"
  end

  desc "Release opal-#{Opal::VERSION}.gem"
  task :release do
    puts "Need to release opal-#{Opal::VERSION}.gem"
  end
end

##
# Documentation
#

begin
  require 'rocco'
rescue LoadError
end

namespace :docs do
  task :clone do
    if File.exists? 'gh-pages'
     Dir.chdir('gh-pages') { sh 'git pull origin gh-pages' }
    else
      FileUtils.mkdir_p 'gh-pages'
      Dir.chdir('gh-pages') do
        sh 'git clone git@github.com:/adambeynon/opal.git .'
        sh 'git checkout gh-pages'
      end
    end
  end

  desc "Copy required files into gh-pages dir"
  task :copy => :opal do
    %w[opal.js opal.debug.js index.html].each do |f|
      FileUtils.cp f, "gh-pages/#{f}"
    end
  end

  desc "rocco"
  task :rocco do
    FileUtils.mkdir_p 'docs'
    %w[builder dependency_builder].each do |src|
      path = "lib/opal/#{src}.rb"
      out  = "docs/#{src}.html"

      File.open(out, 'w+') { |o| o.write Rocco.new(path).to_html }
    end
  end
end

# Takes a file path, reads it and prints out the file size as it is, once
# minified and once minified + gzipped. Depends on uglifyjs being installed
# for node.js
def sizes file
  o = File.read file
  m = uglify o
  g = gzip m

  puts "#{file}:"
  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs -nc', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end

# Gzip code to check file size
def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end
