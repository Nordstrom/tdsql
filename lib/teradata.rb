require "#{File.expand_path File.dirname(__FILE__)}/../terajdbc4.jar"
require 'java'
require 'jdbc/teradata'

java_import java.sql.Types
Jdbc::Teradata::load_driver

class Teradata
	# http://docs.oracle.com/javase/6/docs/api/constant-values.html#java.sql.Types
	STRING_SQL_TYPES = [1, -9, 12, -15, 91]

	# https://www.ruby-forum.com/topic/202574
	def self.open(host, options)
		db = new(host, options)
	  yield db
	rescue Object => e
		raise e
	ensure
		db and db.close
	end

	def initialize(host, options)
		@connection = java.sql.DriverManager.get_connection(
	    "jdbc:teradata://#{host[:hostname]}/tmode=ANSI,charset=UTF8", host[:username], host[:password])
		@options = options
	end

	def close()
		@connection.close
	end

	def select(sql, parameters, timeout=120)
		sql_statement = @connection.create_statement
    sql_statement.setQueryTimeout(timeout)

    # Set sql parameters on the statement
    # parameters.each { |k, v| sql_statement.setObject(k, v) }

    # Execute the Teradata command
    begin
      recordset = sql_statement.execute_query(sql)
    rescue com.teradata.jdbc.jdbc_4.util.JDBCException => e
    	raise TeradataError.new "Database exception: #{e.message}"
    end

    columns = self.load_metadata(recordset)

    return Enumerator.new do |yielder|
    	while (recordset.next) do
    		yielder.yield self.build_row(recordset, columns)
    	end
    end

   	# while (recordset.next) do
   	# 	yield self.build_row(recordset, columns)
   	# end
	end

	def build_row(recordset, columns)
		row = {}
		# raise columns.inspect
    columns.each_with_index do |column, i|
      if STRING_SQL_TYPES.include? column[:type]
      	value = recordset.getString(i+1)
      else
      	value = recordset.getObject(i+1)
      end
      row[column[:name]] = value.nil? ? @options[:nullstring] : value
    end
    # puts row.inspect
    return row
	end

	def load_metadata(recordset)
		recordset_metadata = recordset.getMetaData()
  	num_columns = recordset_metadata.getColumnCount()

	  columns = []
	  (1..num_columns).each do |i|
	  	columns.push({
	  		name: recordset_metadata.getColumnName(i), 
	  		type: recordset_metadata.getColumnType(i)
	  	})
	  end
	  columns
	end
end

class TeradataError < RuntimeError
end
