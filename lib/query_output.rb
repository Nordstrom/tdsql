
class QueryOutput
	def initialize(configuration)
		@configuration = { delimiter: ',', quotechar: '"', header: true}.merge(configuration.to_h)
	end

	def stream(results, writer)
		headers = nil
		for row in results
			if headers.nil?
				headers = row.keys()

				# Print the header row
				if @configuration[:header] == true
					writer.puts headers.join(@configuration[:delimiter])
				end
			end

			headers.each_with_index do |header, i|
				col_value = row[header]
				# If the column value contains the quote or delimiter characters then wrap the value in quotes
				if quote_value?(col_value)
          col_value.gsub!(@configuration[:quotechar], "\\#{@configuration[:quotechar]}")
					col_value = "#{@configuration[:quotechar]}#{col_value}#{@configuration[:quotechar]}"
				end
				writer.print col_value
				if i < headers.length - 1
					writer.print @configuration[:delimiter]
				else
					writer.print "\n"
				end
			end
		end
	end

	private

	def quote_value?(value)
		return false unless value.class == String
		(value.include? @configuration[:delimiter]) or (value.include? @configuration[:quotechar])
	end

end
