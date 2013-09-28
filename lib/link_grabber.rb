require 'net/https'
require 'URI'
require 'irc_commands'

class LinkGrabber

	def self.read_HTML(url)

		if url.include?('https')
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Get.new(uri.request_uri)
			request.basic_auth("username", "password")
			response = http.request(request)
			response = response.body
			title = /<title>(.*)<\/title>/.match(response)[1]
		else
			uri = URI(url)
			response = Net::HTTP.get(uri)
			title = /<title>(.*)<\/title>/.match(response)[1]
		end

		IRCcommands.say_in_chan("Page Title: #{title}")
	end

end