require "#{File.dirname(__FILE__)}/lib/blindhorse"

EM.run do
  EM.start_server "127.0.0.1", "6378", Blindhorse::Server do |c|
    c.store = Redis::Namespace.new "blindhorse", :redis => ::Redis.new

    location = c.location(0, 0, 0).create.add_room c.room.create.uuid
  end
end
