module Blindhorse
  module Modelable
    def player *args; pl = Player.new *args; pl.store = @store; pl end
    def room *args; r = Room.new *args; r.store = @store; r end
  end
  
  class Model; attr_accessor :store end
  
  class Player < Model
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