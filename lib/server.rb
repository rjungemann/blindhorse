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
					send_data "What is your password?\n>> "
				else
					send_data "And what would you like your password to be?\n>> "
				end

				return false
			elsif not @player.signed_in?
				password = data.strip

				if @player.exists?
					@player.signin password

					send_data "You're #{@player.signed_in? ? 'now' : 'not'} " +
						"signedin.\n>> "
				else
					@player.create
					@player.password = password
					@player.signin password
					@player.position! 0, 0, 0

					send_data "Your account has been created!\n>> "
				end

				return false
			else
				true
			end
    end
  end
end
