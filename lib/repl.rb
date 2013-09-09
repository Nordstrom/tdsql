# Use the readline package
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/readline/rdoc/Readline.html
require 'readline'
class Repl
	def initialize(sql_executor, stdin, stdout) 
		loop do
			stdout.print(">> ")
			input = stdin.gets.chomp!
			if input == '\q'
				return
			end
			stdout.puts(input)
		end
	end
end