module VirtualBox
  # When a VM uses NAT as its NIC type, VirtualBox acts like its
  # own private router for all virtual machines. Because of this,
  # the host machine can't access services within the guest machine.
  # To get around this, NAT supports port forwarding, which allows the
  # guest machine services to be forwarded to some port on the host 
  # machine.
  class ForwardedPort < AbstractModel
    attribute :parent, :readonly => true
    attribute :name
    attribute :instance, :default => "0"
    attribute :device, :default => "pcnet"
    attribute :protocol, :default => "TCP"
    attribute :guestport
    attribute :hostport
    
    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<ForwardedPort>]
      def populate_relationship(caller, data)
        relation = Proxies::Collection.new(caller)
        
        caller.extra_data.each do |key, value|
          next unless key =~ /^(VBoxInternal\/Devices\/(.+?)\/(.+?)\/LUN#0\/Config\/(.+?)\/)Protocol$/i
          
          port = new({
            :parent => caller,
            :name => $4.to_s,
            :instance => $3.to_s,
            :device => $2.to_s,
            :protocol => value,
            :guestport => caller.extra_data["#{$1.to_s}GuestPort"],
            :hostport => caller.extra_data["#{$1.to_s}HostPort"]
          })
          
          port.existing_record!
          
          relation.push(port)
        end
        
        relation
      end
      
      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        data.each do |fp|
          fp.save
        end
      end
    end
    
    def initialize(data={})
      super()
      populate_attributes(data)
    end
    
    # Validates a forwarded port.
    def validate
      super
      
      validates_presence_of :parent
      validates_presence_of :name
      validates_presence_of :guestport
      validates_presence_of :hostport
    end
    
    # Saves the forwarded port.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save(raise_errors=false)
      return true if !new_record? && !changed?
      
      if !valid?
        raise Exceptions::ValidationFailedException.new(errors) if raise_errors
        return false
      end
      
      destroy(raise_errors) if name_changed?
      
      parent.extra_data["#{key_prefix}Protocol"] = protocol
      parent.extra_data["#{key_prefix}GuestPort"] = guestport
      parent.extra_data["#{key_prefix}HostPort"] = hostport
      result = parent.extra_data.save(raise_errors)
      
      clear_dirty!
      existing_record!
      
      result
    end
    
    # Destroys the port forwarding mapping.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy(raise_errors=false)
      results = []

      if !new_record?
        results << parent.extra_data.delete("#{key_prefix(true)}Protocol", raise_errors)
        results << parent.extra_data.delete("#{key_prefix(true)}GuestPort", raise_errors)
        results << parent.extra_data.delete("#{key_prefix(true)}HostPort", raise_errors)
        
        new_record!
      end
      
      results.empty? || results.all? { |o| o == true }
    end
    
    # Relationship callback when added to a collection. This is automatically
    # called by any relationship collection when this object is added.
    def added_to_relationship(parent)
      write_attribute(:parent, parent)
    end
    
    # Returns the prefix to be used for the extra data key. Forwarded ports
    # are created by simply setting {ExtraData} on a {VM}. This class hides most
    # of the inner workings of it, but it requires a common prefix. This method
    # generates that.
    #
    # @return [String]
    def key_prefix(old_name=false)
      name_value = old_name && name_changed? ? name_was : name
      "VBoxInternal\/Devices\/#{device}\/#{instance}\/LUN#0\/Config\/#{name_value}\/"
    end
  end
end