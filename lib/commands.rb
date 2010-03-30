module Blindhorse
  module Commands
    def look
      position = @player.position
      loc = location(*position)
      room = room(loc.rooms.last)
      
      players = loc.players.reject { |name| name == @player.name }
      players_description = if players.empty?
        ""
      elsif players.size < 2
        "#{players.last}" + " is here. "
      else
        first_players = players[0..-2].join(", ")
        
        "You notice that #{first_players} and #{players.last}" + " are here. "
      end
      
      if room.exists?
        room_name = (room && room.name.blank? ? '' : "#{room.name} ")
        room_description = (room && room.description.blank? ? '' :
          room.description + " ")
        exits = [:north, :south, :east, :west, :up, :down].collect { |direction|
          room.exit?(direction) ? direction : nil
        }.compact
        
        exits_description = if exits.empty?
          ""
        elsif exits.size < 2
          "There is an exit to the #{exits.last.to_sym}. "
        else
          first_exits = exits[0..-2].collect { |i| i.to_sym }.join(", ")
          
          "There are exits to the #{first_exits}, and to the #{exits.last.to_sym}. "
        end 
      
        send_data "=> " + room_name + position.to_json + ". " +
          room_description + players_description + exits_description + "\n"
      else
        send_data "=> " + position.to_json + players_description + "\n"
      end
    end
    
    def walk direction
      position = @player.position
			sum = *position.sum(Direction.offset(direction))
    	new_location = location(*sum).create
    	room = room(new_location.rooms.first)

			if room.exists?
      	location(*position).remove_player @player.name
      	new_location.add_player @player.name
			end
      
      look
    end

    def exit; close_connection_after_writing end
  end
  
  module RestrictedCommands
    def go direction
			position = @player.position
			sum = *position.sum(Direction.offset(direction))

      location(*position).remove_player @player.name
      location(*sum).create.add_player @player.name
      
      look
    end
    
    def create_room name = nil, description = nil
      r = room().create
      r.name, r.description = name, description
      
			location(*@player.position).add_room r.uuid
    end
  end
end
