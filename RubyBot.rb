require 'socket'

class IRCBot

	def initialize(name, server, port, channel)
		@channel = channel
		@name = name
		@socket = TCPSocket.open(server, port)
		@inChan = false
		say "NICK #{name}"
		say "USER #{name} 0 * #{name}"
		say "JOIN ##{channel}"
	end

	#say message to server
	def say(message)
		puts 'SERV >> ' + message
		@socket.puts message
	end

	#say message to specified channel
	def say_in_chan(message)
		if @inChan
			say "PRIVMSG ##{@channel} :#{message}"
		end
	end

	def quit(quitmsg = "cya nerds")
		say_in_chan quitmsg
		say "Quit"
	end

	def run
		until @socket.eof? do
			message = @socket.gets
			puts 'SERV << ' + message

			#kind of a hackish way to determine but it works
			if message.include?('366')
				@inChan = true
				puts 'INFO >> Joined channel successfuly'
			end

			if message.include?('PING')
				say 'PONG :pingis \n'
			end

			if message.include?('hi ' + @name)
				say_in_chan 'shut up nerd'
			end

			if message.include?('now quit')
				quit
			end

		end
	end
end

name = 'testbot' + rand(1000000).to_s
bot = IRCBot.new(name, "irc.rizon.net", 7000, 'rubybottest')
bot.run