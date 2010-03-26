require 'rubygems'
require 'eventmachine'
require 'redis'
require 'redis/namespace'
require 'json'
require "#{File.dirname(__FILE__)}/utils"
require "#{File.dirname(__FILE__)}/models"

module Blindhorse
  module Commands
    def look
      position = player("admin").position
      room = room(*position)
      
      room_name = (room && room.name.blank? ? '' : "#{room.name} ")
      room_description = (room && room.description.blank? ? '' :
        ": #{room.description} ")
      
      send_data "=> " + room_name + position.to_json + room_description + "\n"
    end

    def go direction
      player = player("admin")

      player.position! *player.position.sum(Direction.offset(direction))
      
      look
    end
    
    def walk direction
      player = player("admin")
      position = player.position
      sum = position.sum(Direction.offset(direction))
      
      player.position! *sum if room(*player.position).exists?
      
      look
    end

    def exit; close_connection_after_writing end
  end
  
  module RestrictedCommands
    def create_room name = nil, description = nil
      position = player("admin").position
      room = room(*position).create
      room.name, room.description = name, description
    end
  end
  
  class Server < EventMachine::Connection
    include Modelable
    include Interpretable
    include RestrictedCommands
    
    attr_accessor :store

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
  EM.start_server "127.0.0.1", "6378", Blindhorse::Server do |c|
    c.store = Redis::Namespace.new "blindhorse", :redis => Redis.new
    
    c.player("admin").create.position! 0, 0, 0
  end
end