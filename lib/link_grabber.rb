require 'net/http'
require 'irc_commands'

class LinkGrabber

	#open and read HTML from a given url
	def self.read_HTML(msg, limit = 10)
		#ignore images, no page titles there
		return if /\.(jpg|jpeg|bmp|png|tiff|gif$)/.match(msg) != nil

		#find the url in the string, change HTTPS to HTTP because Net::HTTP is cheeky
		url = ""
		msg.split.each { |w| url = w.sub(/^https/, "http") if w.include?("http") }

		if limit == 0
			puts "ERR >> Redirected too many times, failed to fetch HTML"
			return IRCcommands.say_in_chan("Redirected too many times, I won't put up with this shit")
		end

		begin
			response = Net::HTTP.get_response(URI(url))
		rescue URI::InvalidURIError
			puts "ERR >> Invalid URI: #{url}"
			return
		end

		case response
		when Net::HTTPSuccess then
			html = response.read_body
			begin
				title = /<title>(.*)<\/title>/.match(html)[1]
				return IRCcommands.say_in_chan("\x02Page Title:\x02 #{title}")
			rescue NoMethodError
				return puts "Unable to fetch page title"
			end
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