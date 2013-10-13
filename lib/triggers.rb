require 'irc_commands'
require 'database'
require 'link_grabber'
require 'decision'
require 'define'
require 'convert'
require 'quotes'
require 'youtube'

class Triggers

	def self.set_name(name)
		@name = name
	end

	#split message into logical parts
	def self.parse_message(message)
		@triggers = {
		#["hi #{@name}", "hey #{@name}", "sup #{@name}"] => proc { hello },
		["now quit"] => proc { IRCcommands.quit(@user) },
		["!admin"] => proc { IRCcommands.admin(@msg, @user) },
		["http"] => proc { LinkGrabber.read_HTML(@msg) },
		["!decide", "!decide help"] => proc { Decision.decide(@msg) },
		["!8ball"] => proc { Decision.eight_ball },
		#["weed", "pot", "ganja", "420", "marijuana", "blaze"] => proc { four_twenty },
		["!define", "!define help"] => proc { Define.define(@msg) },
		["!convert", "!convert help"] => proc { Conversion.convert(@msg) },
		["!list ignored"] => proc { Database.list_ignored_users },
		["!ignore"] => proc { Database.ignore_user(@msg.split[1], @user) },
		["!unignore"] => proc { Database.unignore_user(@msg.split[1], @user) },
		["!yell"] => proc { Database.get_uppercase_quote() },
		["!quote"] => proc { Quotes.handle_quote(@msg, @user) },
		["!yt"] => proc { Youtube.search(@msg) },
		["!last"] => proc { IRCcommands.say_in_chan("#{@last_caps_quote_user} said that") if not nil }
		}

		@parts = message.split

		#regular channel message
		if message.include?("PRIVMSG")
			@user = @parts[0]
			type = @parts[1]
			@chan = @parts[2]
			@msg = @parts[3..-1].join(" ")[1..-1]

			#pm/query, allow us to send commands for Zyzz to say
			if @chan == @name && Database.is_admin?(@user)
				IRCcommands.say(@msg.split[1..-1].join(" ")) if @msg.split[0] == "say"
			end

			if !(Database.is_ignored?(@user))
				if /^[A-Z\d;:\-\!\#\*()`'",\/<>@%\$\^\+\=\~\s*]{4,}$/.match(@msg) != nil && !(@msg.include?("VERSION"))
					Database.add_uppercase_quote(@user, @msg)
					caps_quote = Database.get_uppercase_quote
					@last_caps_quote_user = caps_quote[0]
					IRCcommands.say_in_chan(caps_quote[1])
				end
				#search the message for triggers, and call proc
				@triggers.each do |k, v|
					if k.any? {|t| @msg.downcase.include?(t) }
						v.call
					end
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