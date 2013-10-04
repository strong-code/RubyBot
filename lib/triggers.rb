require 'irc_commands'
require 'database'
require 'link_grabber'
require 'decision'

class Triggers

	@triggers = {
		"hi #{@name}" => proc { hello },
		"now quit" => proc { quit },
		"!admins" => proc { Database.active_admins },
		"http" => proc { LinkGrabber.read_HTML(@msg) },
		"!decide" => proc { Decision.decide(@msg) },
		"!8ball" => proc { Decision.eight_ball }
		}

	def self.set_name(name)
		@name = name
	end

	#split message into logical parts
	def self.parse_message(message)

		@parts = message.split

		#regular channel message
		if message.include?("PRIVMSG")
			@user = @parts[0]
			type = @parts[1]
			@chan = @parts[2]
			@msg = @parts[3..-1].join(" ")[1..-1]

			#puts "MSG << #{@msg}"

			#search the message for triggers, and call proc
			@triggers.each do |k, v|
				if @msg.downcase.include?(k)
					v.call
				end
			end
		end
	end

	#respond to users in a personable manner
	def self.hello
		responses = ["hi", "hello", "sup", "hej", "hola", "yo", "hey"]
		name = /(.*)\!/.match(@user).to_s.chomp("!")[1..-1]
		IRCcommands.say_in_chan(responses.sample + " #{name}")
	end

	#quit with default message if nothing is supplied
	def self.quit(quitmsg = "cya nerds")
		if Database.is_admin?(@user)
			IRCcommands.say_in_chan quitmsg
			say "QUIT"
		else
			IRCcommands.say_in_chan("You aren't allowed to issue that command, sorry")
		end
	end

end