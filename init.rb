require 'rubygems'
require 'eventmachine'
require "#{File.dirname(__FILE__)}/vendor/em-websocket/lib/em-websocket"
require "#{File.dirname(__FILE__)}/vendor/spork/lib/spork"
require "#{File.dirname(__FILE__)}/lib/blindhorse"

def init c
  c.store = Redis.new
  
  location = c.location(0, 0, 0).create
  
  if location.rooms.empty?
    room = c.room.create
    room.name = "Town Center"
    room.description = "You are standing in the town center. " +
      "There is a large fountain here with a statue of the city's two " + 
      "founders standing on a pedestal in the middle of it."
    
    location.add_room room.uuid
  end
end

EM.run do
  puts "Starting socket server at localhost:6378."
  
  EM.start_server("127.0.0.1", "6378", Blindhorse::Server) { |c| init c }
  
  if(ARGV.find { |arg| ["--websocket", "-w"].include? arg })
    puts "Starting policy server at localhost:843."
    
    EM.start_server("127.0.0.1", "843", Blindhorse::PolicySocket)
    
    puts "Starting websocket server at localhost:6377."
  
    EventMachine::WebSocket.start(:host => "127.0.0.1", :port => 6377) do |ws|
      c = Blindhorse::Server.new
      init c
    
      c.instance_eval { def send *args; self.send_data *args end }
  
      ws.onopen { c.post_init }
      ws.onclose {}
      ws.onmessage { |msg| c.receive_data msg }
    end
  end
end
