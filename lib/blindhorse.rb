require 'rubygems'
require 'eventmachine'
require 'redis'
require 'redis/namespace'
require 'json'
require "#{File.dirname(__FILE__)}/utils"

module Blindhorse
  module Commands
    def look
      send_data "=> " + redis["players:admin:position"] + "\n"
    end

    def go direction
      position = JSON.parse redis["players:admin:position"]
      offset = Direction.offset(direction)

      redis["players:admin:position"] = position.sum(offset).to_json
    end

    def quit
      close_connection_after_writing
    end
  end
  
  class Server < EventMachine::Connection
    include Interpretable
    
    attr_accessor :redis

    def post_init
      permit_interpretables Commands
      
      send_data ">> "
    end

    def receive_data(data)
      interpret data

      send_data ">> "
    end
  end
end

EM.run do
  redis = Redis::Namespace.new "blindhorse", :redis => Redis.new
  
  redis.set_add "players", "admin"
  redis["players:admin:position"] = [0, 0, 0].to_json
  
  EM.start_server "127.0.0.1", "6378", Blindhorse::Server do |connection|
    connection.redis = redis
  end
end