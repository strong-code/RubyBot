require 'database'

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

	#respond to server PING commands with a PONG
	def self.pong
		say 'PONG :pingis'
	end

	#Join a specified channel
	def self.join_chan(channel)
		say "JOIN ##{channel}"
	end

	#part/join a specified channel
	def self.cycle(channel)
		say "PART ##{channel}"
		say "JOIN ##{channel}"
	end

	#quit with default message if nothing is supplied
	def self.quit(user, quitmsg = "cya nerds")
		if Database.is_admin?(user)
			say_in_chan(quitmsg)
			say "QUIT"
		end
	end

	def self.admin(msg, user)
		#non-admins shouldn't be able to use this function
		return if !(Database.is_admin?(user))
		
		msg = msg.split
		command = msg[1]
		user = msg[2] if not nil

		if command == "add"
			add_admin(user)
		elsif command == "remove"
			remove_admin(user)
		elsif command == "list"
			list_admins
		elsif command == "help"
			help
		else 
			return
		end
	end 

	def self.add_admin(user)
		Database.add_admin(user)
		say_in_chan("#{user} is now one of my admins")
	end

	def self.remove_admin(user)
		Database.remove_admin(user)
		say_in_chan("#{user} is no longer one of my admins")
	end

	def self.list_admins
		admins = Database.active_admins
		if admins.length < 1
			say_in_chan("No current admins")
		else
			say_in_chan("Current admins: #{admins.join(", ")}")
		end
	end

	def self.admin_help
		help_doc = "helpdoc goes here"
		say_in_chan(help_doc)
	end

end