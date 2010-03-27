require 'pathname'

PREFIX = Pathname.new(File.dirname(__FILE__)).realpath

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
  sh "gem install eventmachine sinatra redis redis-namespace json uuid --no-ri --no-rdoc"

  sh "mkdir #{script_dir}/vendor" unless File.exists? "#{script_dir}/vendor"
end

desc ""
task :client do
	exec "telnet localhost 6378"
end

desc ""
task :server do
	exec "ruby init.rb"
end

namespace :redis do
	desc ""
	task :start do
		sh "mkdir tmp" unless File.exists? "tmp"
		sh "dtach -n tmp/redis.dtach redis-server"
	end

	desc ""
	task :stop do
		sh %{kill `lsof -i :6379 | ruby -e "STDIN.gets; puts STDIN.gets.split[1]"`}
	end

	desc ""
	task :clean do
		sh "rm -rf tmp" if File.exists? "tmp"
	end
end
