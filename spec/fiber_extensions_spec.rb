$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
require 'never_block'

describe Fiber do
  before do
    @fiber = Fiber.new {puts "I'm a new fiber"}
  end

  it "should be able to set and retrieve fiber local variable" do
    @fiber[:x] = "wow"
    @fiber[:x].should == "wow"
  end

  it "should return nil when trying to retrieve an unset fiber local variable" do
    @fiber[:y].should == nil
  end

  after do
    @fiber = nil
  end
end
