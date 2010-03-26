desc ""
task :default do
  puts "Make sure you have installed XCode from http://developer.apple.com, "
  puts "then type in \"source bashrc\" from this directory. Finally, type in "
  puts "\"rake install\"."
end

desc ""
task :install do
  gem_opts = "--no-ri --no-rdoc"
  script_dir = File.dirname(__FILE__)
  
  sh "mkdir projects tmp"
  sh "mkdir homebrew" unless File.exists? "homebrew"
  sh "cd homebrew && curl -L http://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1"
  
  sh "brew install redis ruby dtach git"
  sh "gem update --system"
  sh "gem install eventmachine sinatra redis redis-namespace json --no-ri --no-rdoc"

  sh "mkdir #{script_dir}/vendor" unless File.exists? "#{script_dir}/vendor"
end