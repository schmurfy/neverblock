$:.unshift File.expand_path(File.dirname(__FILE__))

module KernelExtensions
  def self.included(base)
    base.module_eval do
      alias_method :sleep_original, :sleep
      alias_method :sleep, :sleep_with_em
      
      alias_method :system_original, :system
      alias_method :system, :system_with_em
    end
  end
  
  def sleep_with_em(time= nil)
    return sleep_original(time) unless EM::reactor_running?
    
    Fiber.yield if time.nil?
    return if time <= 0
    fiber = Fiber.current
    EM::add_timer(time){fiber.resume}
    Fiber.yield
  end

  def system_with_em(cmd, *args)
    return system_original(cmd, *args) unless EM::reactor_running?
    
    fb = Fiber.current
    ret = nil
    
    EM::system(cmd, *args) do |output, r|
      ret = case r.exitstatus
              when 127  then  nil
              when 0    then  true
              else            false
            end
      
      fb.resume
    end
    
    Fiber.yield
    
    ret
  end
  
end

Kernel.send(:include, KernelExtensions)

