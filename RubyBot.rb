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
		IRCcommands.say "GHOST #{@@name} #{ARGV[0]}"
		IRCcommands.say "IDENTIFY #{ARGV[0]}"
		IRCcommands.join_chan(@@channel)
		Database.setup_database(@@name, ARGV[1])
	end

	def run
		until @@socket.eof? do
			message = @@socket.gets
			puts 'SERV << ' + message

			if message.include?("PING")
				IRCcommands.pong
			end

			#Have to do this to load hostmask but whatever
			if message.include?(':Password accepted') and @inChan == true
				IRCcommands.cycle(@@channel)
			end

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


bot = IRCBot.new('Zyzz', "irc.rizon.net", 6667, 'bptest')
bot.run