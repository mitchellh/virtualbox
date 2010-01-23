require 'virtualbox/abstract_model/attributable'
require 'virtualbox/abstract_model/dirty'

module VirtualBox
  # A VirtualBox model is an abtraction over the various data
  # items represented by a virtual machine. It allows the gem to
  # define fields on data items which are validated and later can 
  # be persisted. 
  class AbstractModel
    include Attributable
    include Dirty
    
    # Modify populate_attributes to not set dirtiness
    def populate_attributes(attribs)
      ignore_dirty { super }
    end 
    
    # Modify write_attribute to set dirty for the dirty module
    def write_attribute(name, value)
      set_dirty!(name, read_attribute(name), value)
      super
    end
  end
end