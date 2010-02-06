$:.unshift File.expand_path('..')
gem 'activerecord', '2.3.4'
gem 'activesupport', '2.3.4'
require 'active_support'
require 'active_record'

require 'lib/neverblock'
require 'lib/neverblock-mysql'

require 'em-spec/bacon'

EM::spec_backend = EM::Spec::Bacon

EM.describe 'ActiveRecord with fibers' do
  before do
    # create activerecord adapter
    @db = ActiveRecord::Base.establish_connection(:adapter => 'neverblock_mysql', :username => 'root', :database => 'mysql')
    @pool = NB::Pool::FiberPool.new(4)
    
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
  
  should 'be able to execute simple request' do
    @pool.spawn do
      @db.connection.execute("SELECT SLEEP(0)")
      done
    end
  end
  
  should 'allow parallel requests' do
    start_time = Time.new.to_i
    @pool.spawn { @db.connection.execute("SELECT SLEEP(3)") }
    @pool.spawn { @db.connection.execute("SELECT SLEEP(3)") }
    @pool.spawn { @db.connection.execute("SELECT SLEEP(2)") }
    # requests should be executed in parallel and so this request should end
    # more or less 3 seconds after start and not after the previous ones
    @pool.spawn do
      @db.connection.execute("SELECT SLEEP(3)")
      (Time.new.to_i - start_time).should == 3
      done
    end
  end
  
end
