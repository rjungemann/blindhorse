require 'sunshowers'
require 'sinatra/base'

class Sinatra::Request < Rack::Request
  include Sunshowers::WebSocket
end

module Blindhorse
  class WebServer < Sinatra::Base
    configure do
      set :public, "#{File.dirname(__FILE__)}/public"
    end
    
    get "/" do
      if request.ws?
        request.ws_handshake!

        request.ws_io.each do |record|
          ws_io.write_utf8(record)

          break if record == "Goodbye"
        end

        begin
          request.ws_quit!
        rescue
          nil
        end
      end
      "You're not using Web Sockets"
    end
  end
end

run Blindhorse::WebServer.new