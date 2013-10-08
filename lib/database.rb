require 'sqlite3'
require 'irc_commands'

class Database

	def self.setup_database(name, admin_hostmask)
		@@db = SQLite3::Database.new("rubybot.database")
		@@db.execute("CREATE TABLE IF NOT EXISTS Admins (id INTEGER PRIMARY KEY, hostmask TEXT UNIQUE NOT NULL, isadmin BOOLEAN)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Uppercase (id INTEGER PRIMARY KEY, user TEXT NOT NULL, quote TEXT UNIQUE)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Ignored (id INTEGER PRIMARY KEY, user TEXT UNIQUE NOT NULL)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Quotes (id INTEGER PRIMARY KEY, addedby TEXT NOT NULL, quote TEXT UNIQUE NOT NULL)")
		admins_prep = @@db.prepare("INSERT OR IGNORE INTO Admins (hostmask, isadmin) VALUES (?, 1)")
		admins_prep.execute(admin_hostmask)
	end

	#Display the active admins (hostmasks) for the bot
	def self.active_admins
		admins = []

		resp = @@db.execute("SELECT * FROM Admins WHERE isadmin = ?", 1)
		resp.each do |entry|
			admins << entry[1]
		end
		IRCcommands.say_in_chan(admins.join(", "))
	end

	#Return boolean value if user(name) is currently ignored
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

	#Allow an active admin to add a user(name) to the ignore list
	def self.ignore_user(user, admin)
		if is_admin?(admin)
			stm = @@db.prepare("INSERT OR IGNORE INTO Ignored (user) VALUES (?)")
			stm.execute(user)
			IRCcommands.say_in_chan("I am now ignoring \x02#{user}\x02")
		end
	end

	#Allow an active admin to remove a user(name) from the ignore list
	def self.unignore_user(user, admin)
		if is_admin?(admin)
			stm = @@db.prepare("DELETE FROM Ignored WHERE user = ?")
			stm.execute(user)
			return IRCcommands.say_in_chan("No longer ignoring \x02#{user}\x02")
		end
	end

	#Display currently ignore users
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

	#Return a random quote
	def self.rand_quote
		stm = @@db.prepare("SELECT quote FROM Quotes ORDER BY RANDOM() LIMIT 1")
		result = stm.execute
		result.each do |quote|
			return quote[0]
		end
	end

	#Return a quote corresponding to the supplied primary key ID
	def self.get_quote(quote_id)
		stm = @@db.prepare("SELECT quote FROM Quotes WHERE id = ?")
		result = stm.execute(quote_id)
		result.each do |quote|
			return quote[0]
		end
	end

	#Add a quote to the database
	def self.add_quote(user, quote)
		user = /:(.*)!/.match(user)[1]
		stm = @@db.prepare("INSERT OR IGNORE INTO Quotes (addedby, quote) VALUES (?, ?)")
		stm.execute(user, quote)
		quote_id = @@db.execute("SELECT last_insert_rowid();")
		puts "INFO >> Quote #{quote_id[0][0]} to table Quotes by #{user}"
		return quote_id[0][0]
	end

	#Remove a selected quote from the database
	def self.remove_quote(user, quote_id)
		user = /:(.*)!/.match(user)[1]
		stm = @@db.prepare("DELETE FROM Quotes WHERE id = ?")
		puts "INFO >> #{user} removed quote ##{quote_id} from the database" 
		stm.execute(quote_id)
	end

	#Insert an ALLCAPS QUOTE to the database
	def self.add_uppercase_quote(user, quote)
		user = /:(.*)!/.match(user)[1] 
		stm = @@db.prepare("INSERT OR IGNORE INTO Uppercase (user, quote) VALUES (?, ?)")
		puts "INFO >> Adding \"#{quote}\" from #{user} to table Uppercase"
		stm.execute(user, quote)
	end

	#Return an ALLCAPS QUOTE from the database and say it
	def self.get_uppercase_quote
		stm = @@db.prepare("SELECT quote FROM Uppercase ORDER BY RANDOM() LIMIT 1")
		result = stm.execute
		#hacky but we're limiting the statement to 1 so it doesn't matter really
		result.each do |entry|
			return IRCcommands.say_in_chan(entry[0])
		end
	end

	#Return a boolean value if user (hostmask) is an admin
	def self.is_admin?(username)
		hostmask = /.*@(.*)/.match(username)[1].to_s

		result = @@db.execute("SELECT isadmin, hostmask FROM Admins")
		result.each do |entry|
			return true if entry[0] == 1 && entry[1] == hostmask
		end
		return false
	end

end