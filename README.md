Description
-------------------------
A lightweight OSX/Linux command line utility for the [Teradata](http://www.teradata.com/) database server modeled after the Postgres [psql](http://www.postgresql.org/docs/9.2/static/app-psql.html) utility. Built with JRuby to take advantage of JDBC interoperability. The app is designed both to be used directly from the command line by a person or programatically invoked via a sub-process from other scripts like Python or Ruby where Teradata integration is desired but do not want to run on the JVM (JRuby, Jython, etc.)


Installation Instructions
-------------------------
* Ensure jruby is installed and present in the PATH
* Make sure tdsql has execute permissions: 
  chmod +x tdsql
* Create a symlink in /usr/local/bin replacing "~/src" with your clone path:
  ln -s ~/src/tdsql/tdsql /usr/local/bin/tdsql

Usage
--------------------------
Type tdsql --help for a list of parameters.
DB connection information can be provided either with the individual command line args --hostname, --username, and --password or by specifying just a --hostname and have the username and password stored in an external configuration file. If no --hostname is specified, then the first host found in configuration is 
used automatically. 

The sql query to execute can be specified right at the command line via the --command argument or the --file argument can specify a file path containing the command to run. If neither is specified then an interactive REPL session is initiated.

It is not necessary to pass any arguments at all. This will result in a REPL session connected to the default host. 

The tool supports multiple config file locations starting with the tdsql.conf file that is part of the app source. A local config file can be created in the user home directory called .tdsql.conf to override or augment the default settings. Finally a config file path can be specified via the --conf command line arg. 

The format of all config files is like so:

```yaml
timeout: 120

hosts:
	- hostname: [db_host_1]
		username: [db_username]
		password: [db_password]
	- hostname: [db_host_2]
		username: [db_username]
		password: [db_password]
```

Full Usage:

	 --hostname, -h <s>:   Teradata host
   --username, -u <s>:   Teradata username
   --password, -p <s>:   Teradata password
    --command, -c <s>:   Teradata SQL command
  --delimiter, -d <s>:   Column delimiter (default: <tab>)
  --quotechar, -q <s>:   The quote character (default: '"')
       --file, -f <s>:   Teradata sql file
     --output, -o <s>:   File to write the output to
    --timeout, -t <i>:   Command timeout in seconds (default: 120)
         --header, -e:   Print column headers in output
       --conf, -n <s>:   Configuration file path
           --help, -l:   Show this message

Roadmap
--------------------------
* Tests!
* REPL support
* Automated install via homebrew

<!-- https://github.com/jboursiquot/sqlcli/blob/master/lib/sqlcli.rb -->