require 'sqlite3'
require 'irc_commands'

class Database

	def self.setup_database(name, admin_username = "")
		@@db = SQLite3::Database.new("rubybot.database")
		@@name = name
		@@db.execute("CREATE TABLE IF NOT EXISTS Admins (id INTEGER PRIMARY KEY, username TEXT, isadmin BOOLEAN)")
		@@db.execute("INSERT INTO Admins ( username, isadmin ) VALUES ( '#{admin_username}', 1 )")
	end

	def self.is_admin?(username)
		name = /(.*)\!/.match(username).to_s.chomp("!")
		query = @@db.execute("SELECT * FROM Admins WHERE username=#{name[1..-1]}")
	end

end