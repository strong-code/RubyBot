require 'irc_commands'

class Decision

	#simple decision making method
	def self.decide(msg)
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

end