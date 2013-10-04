require 'irc_commands'
require 'database'
require 'link_grabber'
require 'decision'
require 'define'

class Triggers

	@triggers = {
		["hi #{@name}"] => proc { hello },
		["now quit"] => proc { quit },
		["!admins"] => proc { Database.active_admins },
		["http"] => proc { LinkGrabber.read_HTML(@msg) },
		["!decide"] => proc { Decision.decide(@msg) },
		["!8ball"] => proc { Decision.eight_ball },
		["weed", "pot", "ganja", "420", "marijuana"] => proc { four_twenty },
		["!define"] => proc { Define.define(@msg) }
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

			#search the message for triggers, and call proc
			@triggers.each do |k, v|
				if k.any? {|t| @msg.downcase.include?(t) }
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

	#the worst trigger ever made in the history of irc
	def self.four_twenty
		phrases = ["so skoned right now", "ya im hi (on pot )", "is this still cherried ?",
			"wat kinda papers r these?", "ya its #kush lol", "wats up my blaze brother",
			"box hotting my room rite now lmao soo smokey B)", "4 2 0  T I L L  I  D I E",
			"ya i do pot/weed", "hit this bro its fucken frosty", "fuck im rly hi (on weed)",
			"u do ganja rite ??", "jesus = dank", "weed is naturl bro its good 4 u",
			"if ur not smokin ur jokin...", "fuk i think im too hi call 911"]
		IRCcommands.say_in_chan(phrases.sample)
	end

end