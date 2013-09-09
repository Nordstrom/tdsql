require '../lib/configuration'
require "test/unit"
require 'yaml'

class TestConfigurtion < Test::Unit::TestCase
 
  def test_symbolize_keys()
    yaml = """
    hosts: 
      - hostname: foo
        username: frank
        password: pass"""

    hash = Configuration.symbolize_keys(YAML.load(yaml))
    assert_equal({hosts: [{hostname: 'foo', username: 'frank', password: 'pass'}]}, hash)
  end

  def test_basic_load
  	config = Configuration.new(
  		{ hostname: 'foo', username: 'bob', password: 'bob_pass'}, 
  		{ password: 'bob_pass2' })

  	assert_equal('foo', config[:hostname])
  	assert_equal('bob_pass2', config[:password])
  end

  def test_blank_values_ignored()
    config = Configuration.new(
      { hostname: 'foo', username: 'bob', password: 'bob_pass', blah: '', blah2: nil}, 
      { password: 'bob_pass2', foo: nil, foo2: '' })

    assert_equal(false, config.key?(:blah))
    assert_equal(false, config.key?(:blah2))
    assert_equal(false, config.key?(:foo))
    assert_equal(false, config.key?(:foo2))
  end

  def test_hosts_override
  	hash1 = {
  		hosts: [{
					hostname: 'host1', 
					username: 'bob',
					password: 'bob_pass'
				},
				{
					hostname: 'host2',
					username: 'sam',
					password: 'sam_pass'
				}
			]
		}

  	hash2 = {
  		hosts: [{
					hostname: 'host2', 
					username: 'jim',
					password: 'jim_pass'
				},
				{
					hostname: 'host3',
					username: 'frank',
					password: 'frank_pass'
				}
			]
		}

  	config = Configuration.new(hash1, hash2)
  	assert_equal(4, config[:hosts].length)
  	assert_equal('host1', config[:hosts][0][:hostname])
  	assert_equal('jim', config[:hosts][2][:username])
  	assert_equal('host3', config[:hosts][3][:hostname])

  	assert_equal(2, (config[:hosts].find_all { |h| h[:hostname] == 'host2'}).length)
  end

  def test_load_conf_file()
  	config = Configuration.new(
  		{hostname: 'foo', username: 'bob', password: 'bob_pass'}, 
  		'tdsql.conf', 'fake.conf')

  	assert_equal(120, config[:timeout])
  end

  def test_get_active_host_explicit()
  	host_config = { hostname: 'host', username: 'bob', password: 'pass' }
  	config = Configuration.new(host_config)
  	host = config[:host]
  	assert_not_nil(host)
  	assert_equal(host, host_config)
  end

  def test_get_host_default()
  	hosts = [
  		{
  			hostname: 'host1',
  			username: 'bob',
  			password: 'bob_pass'
  		},
  		{
  			hostname: 'host2',
  			username: 'sam',
  			password: 'sam_pass'
  		}
  	]

		config = Configuration.new({hosts: hosts})
		host = config[:host]

  	assert_not_nil(host)
  	assert_equal('host1', host[:hostname])
  	assert_equal('bob', host[:username])
  	assert_equal('bob_pass', host[:password])
  end

  def test_missing_hosts()
  	assert_raise(ConfigError) { Configuration.new({}) }
  end

  def test_missing_hostname()
  	hosts_config = [
  		{
  			hostname: 'host1',
  			username: 'bob',
  			password: 'pass'
  		}
  	]

  	assert_raise(ConfigError) { Configuration.new({hosts: hosts_config, hostname: 'fakehost' }) }
  end

  def test_host_by_hostname()
  	hosts_config = [
  		{
  			hostname: 'host1',
  			username: 'bob',
  			password: 'pass'
  		}
  	]

  	config = Configuration.new({hosts: hosts_config, hostname: 'host1' })
  	host = config[:host]
  	assert_not_nil(host)
  	assert_equal('host1', host[:hostname])
  	assert_equal('bob', host[:username])
  	assert_equal('pass', host[:password])
  end
end