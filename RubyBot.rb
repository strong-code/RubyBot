$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'irc_commands'
require 'triggers'
require 'socket'

class IRCBot

	def initialize(name, server, port, channel)
		@@channel = channel
		@@name = name
		@@socket = TCPSocket.open(server, port)
		@inChan = false
		IRCcommands.set_class_vars(@@socket, channel, name)
		IRCcommands.say "NICK #{name}"
		IRCcommands.say "USER #{name} 0 * #{name}"
		IRCcommands.say "JOIN ##{channel}"
	end

	def run
		until @@socket.eof? do
			message = @@socket.gets
			puts 'SERV << ' + message

			#kind of a hackish way to determine but it works
			if message.include?('366')
				@inChan = true
				puts 'INFO >> Joined channel successfuly'
			end

			if @inChan
				Triggers.parse_message(message)
			end

		end
	end
end

name = 'testbot' + rand(1000000).to_s
bot = IRCBot.new(name, "irc.rizon.net", 7000, 'rubybottest')
bot.run