module Blindhorse
  module Modelable
    def self.model_for *table_syms
    	table_syms.each do |table_sym|
		  	class_eval "def #{table_sym.to_s} *args; " +
					"m = #{table_sym.to_s.camelize}.new *args; " +
					"m.store = @store; m end"
			end
    end

    model_for :player, :room, :location
  end
  
  class Model; attr_accessor :store end
  
  class Player < Model
    module Authenticable
      def password= pass
        salt = Generate.salt

        @store["players:#{@name}:salt"] = salt
        @store["players:#{@name}:hash"] = Generate.hash(pass, salt) 
        
        true
      end

      def check_password pass
        salt = @store["players:#{@name}:salt"]

        @store["players:#{@name}:hash"] == Generate.hash(pass, salt) 
      end
    end
    
    module Signinable
      def signin pass
        @store["players:#{@name}:signedin"] = check_password pass
      end

      def signout
      	@store["players:#{@name}:signedin"] = nil
      end
      
      def signed_in?
        not @store["players:#{@name}:signedin"].blank?
      end
    end
    
    module Authorizable
      attr_accessor :roles
      
      def authorized? role; (@roles ||= []).include? role end
    end
    
    include Authenticable
    include Signinable
    include Authorizable

    attr_reader :name
    
    def initialize name; @name = name end
    def create; @store.set_add "players", @name; self end
    def destroy; @store.set_delete "players", @name; self end
    def exists?; @store.set_member? "players", @name end
    def position; @store["player:#{@name}:location"].split(":").collect &:to_i end
  end
  
  class Room < Model
		attr_reader :uuid
  
    def initialize uuid = nil; @uuid = uuid || Generate.uuid end
    def create; @store.set_add "rooms", @uuid; self end
    def destroy; @store.set_delete "rooms", @uuid; self end
    def name; @store["rooms:#{@uuid}:name"] end
    def name= n; @store["rooms:#{@uuid}:name"]= n end
    def description; @store["rooms:#{@uuid}:description"] end
    def description= d; @store["rooms:#{@uuid}:description"] = d end
    def exists?; @store.set_member? "rooms", @uuid end
    def position; @store["room:#{@uuid}:location"].split(":").collect &:to_i end
    def exit? direction
      sum = *position().sum(Direction.offset(direction))
      key = sum.join(":")
    	
    	exists = @store.set_member? "locations", key
    	number_of_rooms = @store.set_members("locations:#{key}:rooms").size
    	
    	exists && number_of_rooms > 0
    end
  end
  
  class Location < Model
		def initialize x, y, z; @x, @y, @z = x, y, z end
		def create; @store.set_add "locations", key; self end
    def destroy; @store.set_delete "locations", key; self end
    def key; [@x, @y, @z].join(":") end
    def exists?; @store.set_member? "locations", key end

    def add_room uuid
    	@store.set_add "locations:#{key}:rooms", uuid
			@store["room:#{uuid}:location"] = key
    end

    def remove_room uuid
    	@store.set_delete "locations:#{key}:rooms", uuid
    	@store["room:#{uuid}:location"] = nil
    end

    def has_room? uuid; @store.set_member? "locations:#{key}:rooms", uuid end
		def rooms; @store.set_members "locations:#{key}:rooms" end

    def add_player name
    	@store.set_add "locations:#{key}:players", name
    	@store["player:#{name}:location"] = key
    end

    def remove_player name
    	@store.set_delete "locations:#{key}:players", name
			@store["player:#{name}:location"] = nil
    end

    def has_player? name; @store.set_member? "locations:#{key}:players", name end
		def players; @store.set_members "locations:#{key}:players" end
  end
  
  class MockServer
    include Modelable
    
    def initialize store = nil; @store = store || Redis.new end
  end
end
