require 'net/http'
require 'rubygems'
require 'json'
require 'irc_commands'

class Define

	def self.define(msg)
		#shouldnt hard code this in here but im laaaazy
		api_key = "3c58717ad84d01e36b00300b24006cae5d071d3feb690edeb"
		word = msg.split[1]
		part_of_speech = ""
		definition = ""


		url = "http://api.wordnik.com/v4/word.json/#{word}/definitions?limit=3&includeRelated=false&useCanonical=false&includeTags=false&api_key=#{api_key}"
		resp = Net::HTTP.get(URI(url))
		resp = JSON.parse(resp)
		resp.each do |item|
			definition = item["text"]
			part_of_speech = item["partOfSpeech"]
		end

		definition = definition[0..150] << "..." if definition.length > 150

		IRCcommands.say_in_chan("\x02#{word}\x02: (#{part_of_speech}) #{definition}")
	end

end