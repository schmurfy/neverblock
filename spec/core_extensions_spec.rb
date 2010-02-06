$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
require 'never_block'

gem 'activerecord', '2.3.4'
gem 'activesupport', '2.3.4'
require 'active_support'
require 'active_record'

require 'neverblock-mysql'

require 'em-spec/bacon'

EM::spec_backend = EM::Spec::Bacon

EM::describe 'Kernel::system' do
  should 'not block execution' do
    n = 0
    EM::add_periodic_timer(0.5){ n += 1 }
    
    ret = system('sleep 2')
    ret.should == true
    n.should > 2
    done
  end
end

EM::describe 'Kernel::sleep' do
  should 'not block execution' do
    n = 0
    EM::add_periodic_timer(0.5){ n += 1 }
    
    t = Time.new.to_i
    sleep(2)
    (Time.new.to_i - t).should == 2
    n.should > 2
    done
  end
end

