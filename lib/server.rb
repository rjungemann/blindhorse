module Blindhorse  
  class Server < EventMachine::Connection
    include Modelable
    include Interpretable
    include RestrictedCommands
    
    attr_accessor :store

    def post_init
      permit_interpretables Commands
      
      send_data "What is your name?\n>> "
    end

    def receive_data(data)
      if auth! data
		    interpret data

		    send_data ">> "
		  end
    end

    private

    def auth! data
			if not @name
				@name = data.strip
				@player = player(@name)

				if @player.exists?
				  @player.signout
				  
					send_data "What is your password?\n>> "
				else
					send_data "And what would you like your password to be?\n>> "
				end

				return false
			elsif not @player.signed_in?
			  password = data.strip
			  
				if @player.exists?
					if @player.signin password
            send_data "You're now signedin.\n"
            
            look
            
            send_data ">> "
          else
            @name, @player = nil, nil
            
            send_data "The system couldn't sign you in.\n" +
              "What is your name?\n>> "
          end
        elsif password.blank?
          send_data "Please enter a valid password.\n>> "
				else
					@player.create
					@player.password = password
					@player.signin password

					location(0, 0, 0).add_player @player.name

					send_data "Your account has been created!\n>> "
				end

				return false
			else
			  @player.location_init self
				@player.location_unsubscribe
      	@player.location_subscribe
			end
    end
  end
  
  class PolicySocket < EventMachine::Connection
    def receive_data data
      if(data.match /<policy-file-request\s*\/>/)
        puts "PolicySocket: sending a cross-domain file."
        send_data %{<?xml version="1.0"?><cross-domain-policy><allow-access-from domain="*" to-ports="*"/></cross-domain-policy>\0}
      end
    end
  end
end