require 'active_support'

module Blindhorse
  module Modelable
    def self.model_for *table_syms
    	table_syms.each do |table_sym|
		  	class_eval "def #{table_sym.to_s} *args; " +
					"m = #{table_sym.to_s.camelize}.new *args; " +
					"m.store = @store; m end"
			end
    end

    model_for :player, :room
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
      
      def signed_in?
        @store["players:#{@name}:signedin"]
      end
    end
    
    module Authorizable
      attr_accessor :roles
      
      def authorized? role; (@roles ||= []).include? role end
    end
    
    include Authenticable
    include Signinable
    include Authorizable
    
    def initialize name; @name = name end
    def create; @store.set_add "players", @name; self end
    def destroy; @store.set_delete "players", @name; self end
    
    def position
      %w[x y z].collect { |n| @store["players:#{@name}:#{n}"].to_i }
    end
    
    def position! x, y, z
      @store["players:#{@name}:x"] = x
      @store["players:#{@name}:y"] = y
      @store["players:#{@name}:z"] = z
      
      position
    end

    def exists?; @store.set_member? "player", @name end
    def x; @store["players:#{@name}:x"] end
    def x= val; @store["players:#{@name}:x"] = val end
    def y; @store["players:#{@name}:y"] end
    def y= val; @store["players:#{@name}:y"] = val end
    def z; @store["players:#{@name}:z"] end
    def z= val; @store["players:#{@name}:z"] = val end
  end
  
  class Room < Model
    def initialize x, y, z; @x, @y, @z = x, y, z end
    def create; @store.set_add "rooms", key; self end
    def destroy; @store.set_delete "rooms", key; self end
    def key; [@x, @y, @z].join(":") end
    def name; @store["rooms:#{key}:name"] end
    def name= n; @store["rooms:#{key}:name"]= n end
    def description; @store["rooms:#{key}:description"] end
    def description= d; @store["rooms:#{key}:description"] = d end
    def exists?; @store.set_member? "rooms", key end
  end
  
  class MockServer
    include Modelable
    
    def initialize store = nil; @store = store || Redis.new end
  end
end
