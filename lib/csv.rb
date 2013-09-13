require 'csv'

class CsvDatabase
	def self.open(csv_path)
		db = new(csv_path)
	  yield db
	rescue Object => e
		raise e
	ensure
	end

	def initialize(csv_path)
    @csv_path = csv_path
	end

	def select(timeout=120)
    return Enumerator.new do |yielder|
      CSV.foreach(@csv_path, headers: true) do |row|
        yielder.yield row.fields
      end
    end
	end
end