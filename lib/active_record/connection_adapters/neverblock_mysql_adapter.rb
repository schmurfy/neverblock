# Require original mysql adapter as we'll just extend it
require 'active_record/connection_adapters/mysql_adapter'

# Add neverblock's stuff
require 'neverblock'
require 'neverblock-mysql'
require 'active_record/neverblock_connection_pool'

class ActiveRecord::ConnectionAdapters::NeverBlockMysqlAdapter < ActiveRecord::ConnectionAdapters::MysqlAdapter

  # Returns 'NeverBlockMySQL' as adapter name for identification purposes
  def adapter_name
    'NeverBlockMySQL'
  end

  def configure_connection
    NB.neverblock(false) do
      encoding = @config[:encoding]
      execute("SET NAMES '#{encoding}'") if encoding

      # By default, MySQL 'where id is null' selects the last inserted id.
      # Turn this off. http://dev.rubyonrails.org/ticket/6778
      execute("SET SQL_AUTO_IS_NULL=0")
    end
  end

end


class ActiveRecord::Base
  # Establishes a connection to the database that's used by all Active Record objects.
  def self.neverblock_mysql_connection(config) # :nodoc:
      config = config.symbolize_keys
      host     = config[:host]
      port     = config[:port]
      socket   = config[:socket]
      username = config[:username] ? config[:username].to_s : 'root'
      password = config[:password].to_s

      if config.has_key?(:database)
        database = config[:database]
      else
        raise ArgumentError, "No database specified. Missing argument: database."
      end

      # Require the MySQL driver and define Mysql::Result.all_hashes
      unless defined? Mysql
        begin
          require_library_or_gem('mysqlplus')
        rescue LoadError
          $stderr.puts 'mysqlplus is required'
          raise
        end
      end
      MysqlCompat.define_all_hashes_method!

      mysql = NB::DB::FiberedMysqlConnection.init
      mysql.ssl_set(config[:sslkey], config[:sslcert], config[:sslca], config[:sslcapath], config[:sslcipher]) if config[:sslca] || config[:sslkey]

      ::ActiveRecord::ConnectionAdapters::NeverBlockMysqlAdapter.new(mysql, logger, [host, username, password, database, port, socket], config)
    end
end
