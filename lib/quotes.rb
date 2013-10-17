require 'database'
require 'irc_commands'

class Quotes

	def self.handle_quote(msg, user)
		msg = msg.split
		return if msg.length == 1
		quote = msg[2..-1].join(" ")

		#all users can use rand, read and help
		if msg[1].downcase == "rand"
			rand_quote
		elsif msg[1].downcase == "read"
			read_quote(msg[2])
		elsif msg[1].downcase == "help"
			help
		end

		#only admins can add and remove
		if Database.is_admin?(user)
			if msg[1].downcase == "add"
				add_quote(user, quote)
			elsif msg[1].downcase == "remove"
				remove_quote(user, msg[2])
			end
		end

	end

	def self.add_quote(user, quote)	
		quote_id = Database.add_quote(user, quote)
		IRCcommands.say_in_chan("Quote \x02##{quote_id}\x02 added")
	end

	def self.remove_quote(user, quote_id)
		Database.remove_quote(user, quote_id)
		IRCcommands.say_in_chan("Quote \x02##{quote_id}\x02 removed")
	end

	def self.rand_quote
		rand_quote = Database.rand_quote
		if rand_quote == nil
			IRCcommands.say_in_chan("No quotes currently in the database! Try adding one.")
		else
			IRCcommands.say_in_chan(rand_quote)
		end
	end

	def self.read_quote(quote_id)
		quote = Database.get_quote(quote_id)
		if quote == nil 
			IRCcommands.say_in_chan("I couldn't find a quote with id \x02##{quote_id}\x02")
		else
			IRCcommands.say_in_chan(quote)
		end
	end


	def self.help
		help_doc = "Use \x02!quote {add |remove|read|rand}\x02 to handle a quote. This function is only available to admins"
		IRCcommands.say_in_chan(help_doc)
	end

end