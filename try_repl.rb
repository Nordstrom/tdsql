require 'lib/repl'
require 'lib/csv'

def main()
  configuration = {}
  CsvDatabase.open("#{File.expand_path File.dirname(__FILE__)}/test/crime_by_state.csv") do |db|
    Repl.new(db, configuration)
  end
end

if __FILE__ == $PROGRAM_NAME
  main()
end
