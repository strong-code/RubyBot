require 'sqlite3'
require 'irc_commands'

class Database

	def self.setup_database(name)
		@@db = SQLite3::Database.new("rubybot.database")
		@@name = name
		@@db.execute("CREATE TABLE IF NOT EXISTS Triggers (id INTEGER PRIMARY KEY, trigger TEXT, name TEXT, response TEXT, enabled BOOLEAN)")
		@@db.execute("CREATE TABLE IF NOT EXISTS Commands (id INTEGER PRIMARY KEY, command TEXT, response TEXT, enabled BOOLEAN)")
		update_loaded_triggers
	end

	#split the message line into logical parts
	def self.parse_message(message)
		if message.include?("PRIVMSG")
			parts = message.split
			user = parts[0]
			type = parts[1]
			chan = parts[2]
			msg = parts[3..-1].join(" ")[1..-1]

			puts "MSG << #{msg}"

			@@loaded_triggers.each do |k, v|
				if msg.include?(k)
					IRCcommands.say_in_chan(v)
				end
			end

		end

	end

	def self.update_loaded_triggers
		triggers = @@db.execute("SELECT trigger FROM Triggers WHERE enabled")
		responses = @@db.execute("SELECT response FROM Triggers WHERE enabled")
		@@loaded_triggers = Hash.new

		for i in 0..triggers.length-1
			@@loaded_triggers[triggers[i][0]] = responses[i][0]
		end

	end

	def self.test
		@@db.execute("INSERT INTO Triggers ( trigger, name, response, enabled) VALUES ('hi #{@@name}', 'Hi', 'hi m8', 1)")
		p @@db.execute("SELECT * FROM Triggers")
	end

	def self.get_enabled_from_table(table_name)
		loaded = @@db.execute("SELECT name FROM #{table_name} WHERE enabled")
		"#{loaded.length} triggers loaded: " + loaded.join(", ")
	end

	def self.add_trigger(trigger, name, response)
		@@db.execute("INSERT INTO Triggers ( trigger, name, response, enabled ) VALUES ('#{trigger}', '#{name}', '#{response}', 1)")
		"#{name} trigger added successfully"
	end

	def self.remove_trigger(name)
		@@db.execute("DELETE FROM Triggers WHERE name = #{name}")
		"#{name} trigger deleted successfully"
	end

end