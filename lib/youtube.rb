require 'database'
require 'irc_commands'
require 'net/http'
require 'rubygems'
require 'json'

class Youtube

	def self.search(query)
		api_key = "&key=AIzaSyBHQszgBQvZjvOlsLrsGOaRxKNgUvbk_CI"
		base_url = "https://www.googleapis.com/youtube/v3/search?part=snippet"
		query = "&q="+query.split()[1..-1].join("+")
		limit = "&maxResults=1"
		order_by = "&order=viewCount"
		search_url = base_url+query+order_by+limit+api_key
		
		puts search_url

		p Net::HTTP.get(URI.parse(search_url))
	end


end