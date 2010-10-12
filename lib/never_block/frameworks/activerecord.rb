require 'active_record'

# We also need to override the scoped methods to store
# the scope in the fiber context
class ActiveRecord::Base
  def scoped_methods #:nodoc:
    Fiber.current[:"#{self}_scoped_methods"] ||= self.default_scoping.dup
  end
end

