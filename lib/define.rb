require 'net/http'
require 'rubygems'
require 'json'
require 'irc_commands'

class Define

	def self.define(msg)
		return help if msg.split[1] == "help"

		#shouldnt hard code this in here but im laaaazy
		api_key = "3c58717ad84d01e36b00300b24006cae5d071d3feb690edeb"
		word = msg.split[1]
		part_of_speech = ""
		definition = ""

		begin
			url = "http://api.wordnik.com/v4/word.json/#{word}/definitions?limit=3&includeRelated=false&useCanonical=false&includeTags=false&api_key=#{api_key}"
			resp = Net::HTTP.get(URI(url))
			resp = JSON.parse(resp)

			resp.each do |item|
				definition = item["text"]
				part_of_speech = item["partOfSpeech"]
			end
		rescue URI::InvalidURIError
			puts "ERR >> Unable to fetch definition for #{word}"
			return IRCcommands.say_in_chan("Unable to fetch definition for #{word}")
		end

		definition = definition[0..150] << "..." if definition.length > 150

		if definition == ""
			IRCcommands.say_in_chan("No definition found for \x02#{word}\x02")
		else
			IRCcommands.say_in_chan("\x02#{word}\x02: (#{part_of_speech}) #{definition}")
		end
	end

	def self.help
		help_doc = "Use \x02!define\x02 {word} to get both a definition and "\
		"the part of speech for the supplied word."

		IRCcommands.say_in_chan(help_doc)
	end

end