require 'middleman-gh-pages'

task :default => [:build]

namespace :assets do
  task :precompile do
    sh 'middleman build'
  end
end