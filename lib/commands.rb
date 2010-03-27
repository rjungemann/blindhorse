module Blindhorse
  module Commands
    def look
      position = @player.position
      room = room(*position)
      
      room_name = (room && room.name.blank? ? '' : "#{room.name} ")
      room_description = (room && room.description.blank? ? '' :
        ": #{room.description} ")
      
      send_data "=> " + room_name + position.to_json + room_description + "\n"
    end

    def go direction
      @player.position! *@player.position.sum(Direction.offset(direction))
      
      look
    end
    
    def walk direction
      position = @player.position
      sum = position.sum(Direction.offset(direction))
      
      @player.position! *sum if room(*position).exists?
      
      look
    end

    def exit; close_connection_after_writing end
  end
  
  module RestrictedCommands
    def create_room name = nil, description = nil
      position = @player.position
      room = room(*position).create
      room.name, room.description = name, description
    end
  end
end
