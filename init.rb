require "#{File.dirname(__FILE__)}/lib/blindhorse"

EM.run do
  EM.start_server "127.0.0.1", "6378", Blindhorse::Server do |c|
    c.store = ::Redis.new
    
    location = c.location(0, 0, 0).create
    
    if location.rooms.empty?
      room = c.room.create
      room.name = "Town Center"
      room.description = "You are standing in the town center. " + "
        There is a large fountain here with a statue of the city's two " + 
        "founders standing on a pedestal in the middle of it."
      
      location.add_room room.uuid
    end
  end
end
