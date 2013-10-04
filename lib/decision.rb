require 'irc_commands'

class Decision

	#simple decision making method
	def self.decide(msg)
		return help if msg.split[1] == "help"

		r = Random.rand(2)
		if msg.include?(" or ")
			decision = /\s(.*)\sor\s(.*)/.match(msg)[r+1]
		else
			if r == 1
				decision = "yes"
			else
				decision = "no"
			end
		end
		IRCcommands.say_in_chan(decision)
	end

	#8ball decision
	def self.eight_ball
		responses = ["Yes", "No", "Unsure...", "Answer not clear",
					"Definitely not", "Absolutely", "Ask again later",
					"Are you serious? No way...", "Why not?",
					"I see the wisdom in that", "m8 pls..."]
		IRCcommands.say_in_chan(responses.sample)
	end

	def self.help
		help_doc = "Use \x02!decide\x02 {this} or {that} to get a (well informed) decision. "\
		"If no arguments are supplied, eg, \x02!decide\x02 {a question}, the answer returned "\
		"is yes/no. Finally, use \x02!8ball\x02 to get insight on any question."
		IRCcommands.say_in_chan(help_doc)
	end

end