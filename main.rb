require 'trollop'
require "#{File.dirname(__FILE__)}/lib/repl"
require "#{File.dirname(__FILE__)}/lib/configuration"
require "#{File.dirname(__FILE__)}/lib/query_output"
require "#{File.dirname(__FILE__)}/lib/teradata"

@opts = Trollop::options do
  opt :hostname, "Teradata host name", :type => String
  opt :username, "Teradata username", :type => String
  opt :password, "Teradata password", :type => String
  opt :command, "Teradata SQL command", :type => String
  opt :delimiter, "Column delimiter", :type => String, :default => "\t"
  opt :quotechar, "The quote character", :type => String, :default => '"'
  opt :file, "Teradata sql file", :type => String
  opt :output, "File to write the output to", :type => String
  opt :timeout, "Command timeout in seconds", :type => Integer, :default => 60
  opt :header, "Print column headers in output", :default => false
  opt :conf, "Configuration file file path", :type => String
  opt :nullstring, "The string to return for DB nulls", :type => String, :default => "nil"
end

def main()
  # Get config settings from all the following locations. Locations further down 
  # the list override previously defined settings with the same key.

  # TODO: Only read the conf file if it's permissions are 400
  config_locations = [
    "#{File.expand_path File.dirname(__FILE__)}/tdsql.conf", 
    "#{File.expand_path '~/'}/.tdsql.conf", # Hidden conf file in user home directory
    @opts[:conf],
    @opts
  ]

  configuration = Configuration.new(*config_locations)
  sql_cmd = configuration[:sql_cmd]

  Teradata.open(configuration[:host], {nullstring: configuration[:nullstring]}) do |db|
    if sql_cmd.nil?
      Repl.new(db, configuration)
    else
      begin
        results = db.select(configuration[:sql_cmd], configuration[:timeout])
      rescue TeradataError => e
        $stderr.puts "Teradata Error: #{e.message}"
        return 1
      end

      output = QueryOutput.new(configuration)
      if @opts[:output] 
        File.open(@opts[:output], 'w') do |file|
          output.stream(results, file)
        end
      else
        output.stream(results, $stdout)
      end
      return 0
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  rtn_value = main()
  exit rtn_value
end
