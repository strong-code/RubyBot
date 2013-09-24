require 'irc_commands'

class Triggers

	def self.set_name(name)
		@@name = name
	end

	def self.parse_message(message)
		words = message.split

		if message.include?("PING")
			IRCcommands.pong
		end

		if message.include?("hi #{@name}")
			hello
		end
		
		if message.include?("now quit")
			IRCcommands.quit('Quitting now!')
		end
	end

	def self.hello
		IRCcommands.say_in_chan('hi m8')
	end

end