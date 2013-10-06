require 'sqlite3'
require 'irc_commands'

class Database

	def self.setup_database(name, admin_hostmask)
		@@db = SQLite3::Database.new("rubybot.database")
		@@db.execute("CREATE TABLE IF NOT EXISTS Admins (id INTEGER PRIMARY KEY, hostmask TEXT UNIQUE NOT NULL, isadmin BOOLEAN)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Uppercase (id INTEGER PRIMARY KEY, user TEXT NOT NULL, quote TEXT UNIQUE)")
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

	def self.add_uppercase_quote(user, quote)
		user = /:(.*)!/.match(user)[1] 
		stm = @@db.prepare("INSERT OR IGNORE INTO Uppercase (user, quote) VALUES (?, ?)")
		puts "INFO >> Adding #{quote} from #{user} to table Uppercase"
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

		resp = @@db.execute("SELECT isadmin, hostmask FROM Admins")
		resp.each do |entry|
			return true if entry[0] == 1 && entry[1] == hostmask
			#IRCcommands.say_in_chan("#{username} is an admin") if entry[0] == 1 && entry[1] == hostmask
		end
		return false
	end


end