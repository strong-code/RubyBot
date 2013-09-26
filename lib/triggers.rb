require 'irc_commands'
require 'database'

class Triggers

	@triggers = {
		"ping" => proc { IRCcommands.pong },
		"hi #{@name}" => proc { hello },
		"now quit" => proc { quit },
		"who is admin?" => proc { Database.is_admin?("#{@user}") }
		}


	def self.set_name(name)
		@name = name
	end

	#split message into logical parts
	def self.parse_message(message)

		if message.include?("PING")
			IRCcommands.pong
		end

		if message.include?("PRIVMSG")
			parts = message.split
			@user = parts[0]
			type = parts[1]
			@chan = parts[2]
			msg = parts[3..-1].join(" ")[1..-1].downcase

			puts "MSG << #{msg}"

			#search the message for triggers, and call proc
			@triggers.each do |k, v|
				if msg.include?(k.downcase)
					v.call
				end
			end
		end
	end

	#respond to users in a personable manner
	def self.hello
		greetings = ["hi", "hello", "sup", "hej", "hola", "yo"]
		name = /(.*)\!/.match(@user).to_s.chomp("!")
		IRCcommands.say_in_chan(greetings.sample + " #{name[1..-1]}")
	end

	def self.quit(quitmsg = "cya nerds")
		IRCcommands.say_in_chan quitmsg
		say "QUIT"
	end

end