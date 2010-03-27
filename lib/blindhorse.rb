require 'rubygems'
require 'eventmachine'
require 'redis'
require 'redis/namespace'
require 'json'
require "#{File.dirname(__FILE__)}/utils"
require "#{File.dirname(__FILE__)}/models"
require "#{File.dirname(__FILE__)}/commands"

module Blindhorse  
  class Server < EventMachine::Connection
    include Modelable
    include Interpretable
    include RestrictedCommands
    
    attr_accessor :store

    def post_init
      permit_interpretables Commands

      @name, @signedin = nil, false
      
      send_data "What is your name?\n>> "
    end

    def receive_data(data)
    	if not @name
				@name = data.strip
				@player = player(@name)

				if @player.exists?
					send_data "What is your password?\n>> "
				else
					send_data "And what would you like your password to be?\n>> "
				end
			elsif not @player.signed_in?
				password = data.strip

				if @player.exists?
					@player.signin password

					send_data "You're #{@player.signed_in? ? 'now' : 'not'} " +
						"signedin.\n>> "
				else
					@player.create
					@player.password = password
					@player.signin password
					@player.position! 0, 0, 0

					send_data "Your account has been created!\n>> "
				end
    	else
		    interpret data

		    send_data ">> "
		  end
    end
  end
end

EM.run do
  EM.start_server "127.0.0.1", "6378", Blindhorse::Server do |c|
    c.store = Redis::Namespace.new "blindhorse", :redis => Redis.new
  end
end
