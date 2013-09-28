require 'sqlite3'
require 'irc_commands'

class Database

	def self.setup_database(name, admin_username)
		@@db = SQLite3::Database.new("rubybot.database")
		@@name = name
		@@db.execute("CREATE TABLE IF NOT EXISTS Admins (id INTEGER PRIMARY KEY, username TEXT, isadmin BOOLEAN)")
		@@db.execute("INSERT INTO Admins ( username, isadmin ) VALUES ( '#{admin_username}', 1 )")
		@@db.execute("CREATE TABLE IF NOT EXISTS UserGreetings (id INTEGER PRIMARY KEY, username TEXT, greeting TEXT, enabled BOOLEAN)")
	end

	def self.is_admin?(username)
		name = /(.*)\!/.match(username).to_s.chomp("!")
		name = name.strip
		puts name[1..-1]
		query = @@db.execute("SELECT * FROM Admins WHERE username=#{name[1..-1]}")
		p query
	end

	def self.add_user_greeting(username, greeting)
		@@db.execute("INSERT INTO UserGreetings ( username, greeting, enabled ) VALUES ( '#{username}', '#{greeting}', 1 )")
		IRCcommands.say_in_chan("Greeting has been added for #{username}")
	end

	def self.user_has_greeting?(username)
		p @@db.execute("SELECT greeting FROM UserGreetings WHERE username=#{username}")
	end

end