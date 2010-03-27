module Blindhorse
  module Commands
    def look
      position = @player.location
      loc = location(position.x, position.y, position.z)
      room = room(loc.rooms.first)
      
      room_name = (room && room.name.blank? ? '' : "#{room.name} ")
      room_description = (room && room.description.blank? ? '' :
        ": #{room.description} ")
      
      send_data "=> " + room_name + position.to_json + room_description + "\n"
    end

    def go direction
			position = @player.location
			loc = location(position.x, position.y, position.z)
			sum = *position.sum(Direction.offset(direction))
    	new_location = location(sum.x, sum.y, sum.z).create

      loc.remove_player @player.name
      new_location.add_player @player.name
      
      look
    end
    
    def walk direction
      position = @player.location
			loc = location(position.x, position.y, position.z)
			sum = *position.sum(Direction.offset(direction))
    	new_location = location(sum.x, sum.y, sum.z).create
    	room = room(new_location.rooms.first)

			if room.exists?
      	loc.remove_player @player.name
      	new_location.add_player @player.name
			end
      
      look
    end

    def exit; close_connection_after_writing end
  end
  
  module RestrictedCommands
    def create_room name = nil, description = nil
      position = @player.location
      loc = location(position.x, position.y, position.z)
      room = room(location.rooms.first).create

			loc.add_room room.uuid
      
      room.name, room.description = name, description
    end
  end
end
