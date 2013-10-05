require 'irc_commands'

class Conversion

	def self.convert(msg)
		return help if msg.split[1] == "help"

		begin
			weight = /(\d*)[kg|lb]/.match(msg.split[1])[1]
			if msg.include?("kg")
				convert_to_lb(weight.to_i)
			else
				convert_to_kg(weight.to_i)
			end
		rescue Error
			puts "ERR >> #{Error}"
		end
	end

	def self.convert_to_lb(weight)
		weight = Float(weight) * 2.205
		IRCcommands.say_in_chan("Thats #{weight.round(2)}lb")
	end

	def self.convert_to_kg(weight)
		weight = Float(weight) / 2.205
		IRCcommands.say_in_chan("Thats #{weight.round(2)}kg")
	end

	def self.help
		help_doc = "Help doc goes here"
		IRCcommands.say_in_chan(help_doc)
	end
end