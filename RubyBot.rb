#!/usr/bin/env ruby
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'irc_commands'
require 'triggers'
require 'socket'
require 'database'

class IRCBot

	def initialize(name, server, port, channel)
		@@channel = channel
		@@name = name
		@@socket = TCPSocket.open(server, port)
		@inChan = false
		IRCcommands.set_class_vars(@@socket, channel, name)
		IRCcommands.say "USER #{name} 0 * #{name}"
		IRCcommands.say "NICK #{name}"
		IRCcommands.say "IDENTIFY #{ARGV[0]}"
		Triggers.set_name(@@name)
		IRCcommands.join_chan(@@channel)
		Database.setup_database
	end

	def run
		until @@socket.eof? do
			message = @@socket.gets
			puts 'SERV << ' + message

			if !@inChan
				#kind of a hackish way to determine but it works
				if message.include?('366')
					@inChan = true
					IRCcommands.cycle(@@channel)
					puts 'INFO >> Joined channel successfuly'
				end
			else
				Triggers.parse_message(message)

				if message.include?("PING")
					IRCcommands.pong
				end
			end
			
		end
	end
end

bot = IRCBot.new('Zyzz', "irc.rizon.net", 6667, 'lifting')
bot.run