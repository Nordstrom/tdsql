require 'rake/testtask'

# http://rake.rubyforge.org/classes/Rake/TestTask.html
Rake::TestTask.new do |t|
	t.libs << "test"
	t.test_files = FileList['test/test*.rb']
	t.verbose = true
end