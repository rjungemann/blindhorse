require 'rubygems'
require 'eventmachine'
require "em-websocket"
require "#{File.dirname(__FILE__)}/lib/blindhorse"

def init connection
  connection.store = Redis.new
  
  location = connection.location(0, 0, 0).create
  
  if location.rooms.empty?
    room = connection.room.create
    room.name = "Town Center"
    room.description = "You are standing in the town center. " +
      "There is a large fountain here with a statue of the city's two " + 
      "founders standing on a pedestal in the middle of it."
    
    location.add_room room.uuid
  end
  connection
end

EM.run do
  puts "Starting socket server at localhost:6378."
  
  EM.start_server("127.0.0.1", "6378", Blindhorse::Server) { |c| init c }
  
  if(ARGV.find { |arg| ["--websocket", "-w"].include? arg })
    puts "Starting policy server at localhost:843."
    
    EM.start_server("127.0.0.1", "843", Blindhorse::PolicySocket)
    
    puts "Starting websocket server at localhost:6377."
  
    EventMachine::WebSocket.start(:host => "127.0.0.1", :port => 6377) do |ws|
      c = init Blindhorse::Server.new
      
      c.instance_eval { def send *args; self.send_data *args end }
  
      ws.onopen { c.post_init }
      ws.onclose {}
      ws.onmessage { |msg| c.receive_data msg }
    end
  end
end
