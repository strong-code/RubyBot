require 'sqlite3'
require 'irc_commands'

class Database

	def self.setup_database(name, admin_hostmask)
		@@db = SQLite3::Database.new("rubybot.database")
		@@db.execute("CREATE TABLE IF NOT EXISTS Admins (id INTEGER PRIMARY KEY, hostmask TEXT UNIQUE NOT NULL, isadmin BOOLEAN)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Uppercase (id INTEGER PRIMARY KEY, user TEXT NOT NULL, quote TEXT UNIQUE)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Ignored (id INTEGER PRIMARY KEY, user TEXT UNIQUE NOT NULL)")
		admins_prep = @@db.prepare("INSERT OR IGNORE INTO Admins (hostmask, isadmin) VALUES (?, 1)")
		admins_prep.execute(admin_hostmask)
	end

	def self.active_admins
		admins = []

		resp = @@db.execute("SELECT * FROM Admins WHERE isadmin = ?", 1)
		resp.each do |entry|
			admins << entry[1]
		end
		IRCcommands.say_in_chan(admins.join(", "))
	end

	def self.is_ignored?(user)
		user = /:(.*)!/.match(user)[1].rstrip

		stm = @@db.prepare("SELECT user FROM Ignored")
		result = stm.execute

		result.each do |entry|
			if entry[0] == user
				return true
			end
		end
		false
	end

	def self.ignore_user(user, admin)
		if is_admin?(admin)
			stm = @@db.prepare("INSERT OR IGNORE INTO Ignored (user) VALUES (?)")
			stm.execute(user)
			IRCcommands.say_in_chan("I am now ignoring \x02#{user}\x02")
		end
	end

	def self.unignore_user(user, admin)
		if is_admin?(admin)
			stm = @@db.prepare("DELETE FROM Ignored WHERE user = ?")
			stm.execute(user)
			return IRCcommands.say_in_chan("No longer ignoring \x02#{user}\x02")
		end
	end

	def self.list_ignored_users
		ignored_users = []

		stm = @@db.prepare("SELECT user FROM Ignored")
		result = stm.execute

		result.each do |entry|
			ignored_users << entry[0]
		end

		if ignored_users.join(", ") == ""
			IRCcommands.say_in_chan("I am not currently ignoring anyone")
		else
			IRCcommands.say_in_chan("\x02Ignoring messages from:\x02 #{ignored_users.join(", ")}")
		end
	end

	def self.add_uppercase_quote(user, quote)
		user = /:(.*)!/.match(user)[1] 
		stm = @@db.prepare("INSERT OR IGNORE INTO Uppercase (user, quote) VALUES (?, ?)")
		puts "INFO >> Adding \"#{quote}\" from #{user} to table Uppercase"
		stm.execute(user, quote)
	end

	def self.get_uppercase_quote
		stm = @@db.prepare("SELECT quote FROM Uppercase ORDER BY RANDOM() LIMIT 1")
		result = stm.execute
		#hacky but we're limiting the statement to 1 so it doesn't matter really
		result.each do |entry|
			return IRCcommands.say_in_chan(entry[0])
		end
	end

	def self.is_admin?(username)
		hostmask = /.*@(.*)/.match(username)[1].to_s

		result = @@db.execute("SELECT isadmin, hostmask FROM Admins")
		result.each do |entry|
			return true if entry[0] == 1 && entry[1] == hostmask
			#IRCcommands.say_in_chan("#{username} is an admin") if entry[0] == 1 && entry[1] == hostmask
		end
		return false
	end


end