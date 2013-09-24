class IRCcommands

	def self.set_class_vars(socket, channel, name)
		@@socket = socket
		@@channel = channel
		@@name = name
	end

	#say message to server
	def self.say(message)
		puts 'SERV >> ' + message
		@@socket.puts message +"\n"
	end

	#say message to specified channel
	def self.say_in_chan(message)
		puts 'MSG >> ' + message
		@@socket.puts "PRIVMSG ##{@@channel} :#{message}\n"
	end

	#quit qith specified or default message
	def self.quit(quitmsg = "cya nerds")
		say_in_chan quitmsg
		say "Quit"
	end

	def self.pong
		say 'PONG :pingis'
	end

	def self.join_chan(channel)
		say "JOIN ##{channel}"
	end

	def self.cycle(channel)
		say "PART ##{channel}"
		say "JOIN ##{channel}"
	end


end