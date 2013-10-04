require 'net/http'
require 'irc_commands'

class LinkGrabber

	#open and read HTML from a given url
	def self.read_HTML(url, limit = 10)
		return if /\.(jpg|jpeg|bmp|png|tiff$)/.match(url) != nil

		url = url.sub(/^https/, "http") if url.include?("https")

		raise ArgumentError, "Redirected more than #{10} times, failed to fetch html" if limit == 0

		begin
			response = Net::HTTP.get_response(URI(url))
		rescue URI::InvalidURIError
			puts "ERR >> Invalide URI: #{url}"
			IRCcommands.say_in_chan("That looks like an invalid URL m8")
			return
		end

		case response
		when Net::HTTPSuccess then
			html = response.read_body
			puts "hurrr im searching for title anyways"
			title = /<title>(.*)<\/title>/.match(html)[1]
			IRCcommands.say_in_chan("\x02Page Title:\x02 #{title}")
		when Net::HTTPRedirection then
			location = response['location']
			puts "INFO >> Redirected to #{location}"
			read_HTML(location, limit-1)
		else
			IRCcommands.say_in_chan("Unable to fetch page title for #{url}. Received #{response.value} instead :(")
			puts "ERR >> Unable to reach #{url}. Received #{response.value}"
		end
	end

end