require 'yaml'

# Encapsulates configuration settings for tdsql
class Configuration
	def initialize(*args)
		@config_settings = {}

		args.each do |arg|
			if arg.nil?
				next
			elsif arg.class == Hash
				merge_hashes @config_settings, arg
			elsif arg.class == String and File.exist?(arg)
				file_settings = Configuration.symbolize_keys(YAML.load_file(arg))
				merge_hashes @config_settings, file_settings
	  	end
	  end

	  @config_settings[:host] = determine_host()
	  @config_settings[:sql_cmd] = determine_sql_cmd()
		@config_settings[:ddl_cmd] = determine_ddl_cmd()
	end

	def [](key)
    @config_settings[key]
  end

  def inspect()
  	@config_settings.inspect
  end

  def keys()
  	@config_settings.keys()
  end

  def key?(key)
  	@config_settings.key? key
  end

  def to_h()
  	@config_settings.to_hash
  end

  private

  def determine_host()
		host = nil
		# Check if all the host details exist in config
		host_keys = [:hostname, :username, :password]
		if host_keys.all? {|k| @config_settings.key?(k) }
			host = {}
			host_keys.each {|k| host[k] = @config_settings[k]}
			return host
		end

		hosts = @config_settings[:hosts]
		if hosts.nil? or hosts.length == 0
			raise ConfigError, 'No hosts specified in configuration'
		end

		hostname = @config_settings[:hostname]
		if not hostname.nil?
			host = (hosts.find_all { |host| host[:hostname] == hostname }).last
			raise(ConfigError, "No host #{hostname} specified in configuration") if host.nil?
		else
			host = hosts.first
		end

		# Clone the hash so we aren't modifying the underlying config data. Then
		# tack the hostname on.
		host = host.clone()

		# Validate that the host has all the required keys
		if not host_keys.all? {|k| host.key?(k)}
			raise ConfigError, "Host #{hostname} must have username and password specified"
		end

		host
	end

  def determine_sql_cmd()
  	if not blank?(@config_settings[:file])
    	raise ConfigError, "File #{@config_settings[:file]} does not exist" unless File.exist?(@config_settings[:file])

	    File.open(@config_settings[:file], 'rb') do |file|
	      return file.read
	    end
	  elsif not blank?(@config_settings[:command])
	    @config_settings[:command].strip().delete('"')
	  else
	    return nil
	  end
	end

	def determine_ddl_cmd()
		if not blank?(@config_settings[:ddlfile])
			raise ConfigError, "File #{@config_settings[:ddlfile]} does not exist" unless File.exist?(@config_settings[:ddlfile])

			File.open(@config_settings[:ddlfile], 'rb') do |file|
				return file.read
			end
		elsif not @config_settings[:ddl].nil? and not blank?(@config_settings[:ddl])
			@config_settings[:ddl].strip().delete('"')
		else
			return nil
		end
	end

	# Performs a recursive merge on nested Hashes
  def merge_hashes(hash1, hash2)
  	for key in hash2.keys()
  		if blank? hash2[key]
  			next
  		elsif not hash1.has_key?(key)
  			hash1[key] = hash2[key]
  		elsif hash1[key].class == Array and hash2[key].class == Array
  			hash1[key] = hash1[key].concat(hash2[key])
  		elsif hash1[key].class == Hash and hash2[key].class == Hash
  			merge_hashes(hash1[key], hash2[key])
  		else
  			hash1[key] = hash2[key]
  		end
  	end
  end

  def blank?(value)
  	value.nil? || (value.class == String and value.empty?)
	end

	def self.symbolize_keys(hash)
		hash.keys.each do |key|
			if hash[key].respond_to?(:each)
				hash[key].each {|o| Configuration.symbolize_keys(o) if o.class == Hash}
			end
			if hash[key].class == Hash
				Configuration.symbolize_keys(hash[key])
			end
  		hash[(key.to_sym rescue key) || key] = hash.delete(key)
  	end
  	hash
	end
end

class ConfigError < RuntimeError
end
