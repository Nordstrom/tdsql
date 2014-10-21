require 'trollop'
require 'csv'
require "#{File.dirname(__FILE__)}/lib/repl"
require "#{File.dirname(__FILE__)}/lib/configuration"
require "#{File.dirname(__FILE__)}/lib/query_output"
require "#{File.dirname(__FILE__)}/lib/teradata"

@opts = Trollop::options do
  opt :hostname, "Teradata host name", :type => String
  opt :username, "Teradata username", :type => String
  opt :password, "Teradata password", :type => String
  opt :command, "Teradata SQL command", :type => String
  opt :delimiter, "Column delimiter", :type => String, :default => ","
  opt :quotechar, "The quote character", :type => String, :default => '"'
  opt :file, "Teradata sql file", :type => String
  opt :output, "File to write the output to", :type => String
  opt :timeout, "Command timeout in seconds", :type => Integer, :default => 60
  opt :header, "Print column headers in output", :default => false
  opt :conf, "Configuration file file path", :type => String
  opt :nullstring, "The string to return for DB nulls", :type => String, :default => "nil"
  opt :stdouterr, "Emit errors to stdout rather than stderr"
  opt :parameters, "The input parameters to the sql command as a JSON string", :type => String
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

  # Gather up any command args that start with "@" and treat them as sql parameters
  # if @opts[:parameters]
  #   @opts[:parameters].each |p| do
  #     p.
  #   end
  # end

  # sql_parameters = {}
  # @opts.each do |k, v|
  #   key = k.is_a?(Symbol) ? k.to_s : k
  #   if key.starts_with("@")
  #     sql_parameters[key] = v
  #   end
  # end

  err_stream = @opts[:stdouterr] ? $stdout : $stderr

  Teradata.open(configuration[:host], {nullstring: configuration[:nullstring]}) do |db|
    if sql_cmd.nil?
      Repl.new(db, configuration)
    else
      begin
        results = db.select(configuration[:sql_cmd], {}, configuration[:timeout])
      rescue TeradataError => e
        err_stream.puts e.message
        # Return a non-zero exit code indicating an error
        return 1
      end

      if @opts[:output]
        headers = nil

        CSV.open(@opts[:output], mode='w', options={col_sep: configuration[:delimiter]}) do |csv|
          for row in results
            if headers.nil?
              headers = row.keys()

              # Print the header row
              if configuration[:header] == true
                csv.add_row headers
              end
            else
              csv.add_row(headers.map { |header| row[header].to_s.strip })
            end
          end
        end
      else
        output = QueryOutput.new(configuration)
        output.stream(results, $stdout)
      end
      return 0
    end
  end
end

# def parse_parameters(parameters)
#   parameters.each |p| do
#     equals_index = p.index("=")
#     if equals_index?
#       p.substring()
#     end
#   end
# end

if __FILE__ == $PROGRAM_NAME
  rtn_value = main()
  exit rtn_value
end
