module VirtualBox
  # Represents the system properties of the system which VirtualBox
  # is running on. These system properties are immutable values which
  # are typically limits or specs of the host system. Some examples
  # of available properties are `Maximum guest RAM size` or
  # `Maximum Devices per SATA Port`.
  #
  # # Retrieving the System Properties
  #
  # Retrieving the system properties is done by calling the {all} method.
  # Since {SystemProperty} inherits from `Hash`, you can treat it just like
  # one. The keys are simply the typical keys downcased with spaces replaced
  # with underscores, and converted to a symbol. An example of accessing
  # system properties is shown below:
  #
  #     properties = VirtualBox::SystemProperty.all
  #     puts properties[:log_history_count]
  #     puts properties[:maximum_guest_ram_size]
  #
  # Since {SystemProperty} is simply a hash, you can also iterate over it,
  # convert it easily to an array, etc.
  class SystemProperty < Hash
    class <<self
      # Returns the hash of all system properties. Each call will invoke a
      # system call to retrieve the properties (as in they're not cached
      # on the class), so if you need to access them many times, please
      # cache them yourself.
      #
      # @return [SystemProperty]
      def all
        raw = Command.vboxmanage("list", "systemproperties")
        parse_raw(raw)
      end

      # Parses the raw output of vboxmanage. This parses the raw output from
      # VBoxManage to parse the system properties.
      #
      # **This method typically won't be used except internally.**
      #
      # @param [String] data The raw output from vboxmanage.
      # @return [SystemProperty]
      def parse_raw(data)
        result = new
        data.split("\n").each do |line|
          next unless line =~ /^(.+?):\s+(.+?)$/
          value = $2.to_s
          key = $1.to_s.downcase.gsub(/\s/, "_")
          result[key.to_sym] = value
        end

        result
      end
    end
  end
end