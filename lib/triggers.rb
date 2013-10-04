require 'irc_commands'
require 'database'
require 'link_grabber'
require 'decision'

class Triggers

	@triggers = {
		"hi #{@name}" => proc { hello },
		"now quit" => proc { quit },
		"who is admin?" => proc { Database.is_admin?("#{@user}") },
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

		#new user has joined
		# if message.include?("JOIN")
		# 	user = @parts[0]
		# 	name = /(.*)\!/.match(user).to_s.chomp("!")[1..-1]
		# 	Database.user_has_greeting?(name)
		# end

		#regular channel message
		if message.include?("PRIVMSG")
			@user = @parts[0]
			type = @parts[1]
			@chan = @parts[2]
			@msg = @parts[3..-1].join(" ")[1..-1]

			puts "MSG << #{@msg}"

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
		responses = ["hi", "hello", "sup", "hej", "hola", "yo"]
		name = /(.*)\!/.match(@user).to_s.chomp("!")[1..-1]
		IRCcommands.say_in_chan(responses.sample + " #{name}")
	end


	#quit with default message if nothing is supplied
	def self.quit(quitmsg = "cya nerds")
		IRCcommands.say_in_chan quitmsg
		say "QUIT"
	end

	def self.add_greeting
		parts = @msg.split
		Database.add_user_greeting(parts[1], parts[3..-1].join)
	end

end