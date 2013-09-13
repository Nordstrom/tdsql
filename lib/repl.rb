# Use the readline package
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/readline/rdoc/Readline.html
# http://bogojoker.com/readline/

require 'readline'
require "terminal-table"

class Repl
	def initialize(db, configuration) 
		# TODO: Cap number of rows to display at once
		while line = Readline.readline('> ', true)
			# TODO: Display header
			table = Terminal::Table.new do |t|
				for row in db.select(line)
					t.add_row row
				end
			end
			puts table
		end
	end
end