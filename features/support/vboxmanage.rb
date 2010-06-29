class VBoxManage
  class << self
    def command(*args)
      args = args.dup.flatten
      args.unshift("-q")
      "VBoxManage #{args.join(" ")}"
    end

    def execute(*args)
      cmd = command(*args)
      result = `#{cmd}`.chomp
      raise Exception.new("Failed command: #{cmd}") if $?.exitstatus != 0
      result
    end

    # Gets the extra data for a VM of the given ID and returns it in
    # hash format.
    def extra_data(name)
      output = execute("getextradata", name, "enumerate")

      output.split("\n").inject({}) do |acc, line|
        acc[$1.to_s] = $2.to_s if line =~ /^Key: (.+?), Value: (.+?)$/
        acc
      end
    end

    # Gets the info for a VM and returns it in hash format.
    def vm_info(name)
      output = begin
        execute("showvminfo", name, "--machinereadable")
      rescue Exception
        ""
      end

      output.split("\n").inject(OrderedHash.new) do |acc, line|
        if line =~ /^"?(.+?)"?=(.+?)$/
          key = $1.to_s
          value = $2.to_s
          value = $1.to_s if value =~ /^"(.*?)"$/
          acc[key] = value
        end

        acc
      end
    end

    # Parses the storage controllers out of VM info output and returns
    # it in a programmer-friendly hash.
    def storage_controllers(info)
      raw = info.inject({}) do |acc, data|
        k,v = data

        if k =~ /^storagecontroller(.+?)(\d+)$/
          subkey = $2.to_s
          acc[subkey] ||= {}
          acc[subkey][$1.to_s.to_sym] = v
        end

        acc
      end

      raw.inject({}) do |acc, data|
        k,v = data
        acc[v.delete(:name)] = v
        acc
      end
    end

    # Parses the shared folders out of the VM info output and returns
    # it in a programmer-friendly hash.
    def shared_folders(info)
      raw = info.inject({}) do |acc, data|
        k,v = data

        if k =~ /^SharedFolder(.+?)MachineMapping(\d+)$/
          subkey = $2.to_s
          acc[subkey] ||= {}
          acc[subkey][$1.to_s.downcase.to_sym] = v
        end

        acc
      end

      raw.inject({}) do |acc, data|
        k,v = data
        acc[v.delete(:name)] = v
        acc
      end
    end

    # Parses the network adapters out of the VM info output and
    # returns it in a hash.
    def network_adapters(info)
      valid_keys = %W[natnet macaddress cableconnected hostonlyadapter]

      info.inject({}) do |acc, data|
        k,v = data
        if k =~ /^nic(\d+)$/
          acc[$1.to_i] ||= {}
          acc[$1.to_i][:type] = v
        elsif k=~ /^(.+?)(\d+)$/ && valid_keys.include?($1.to_s)
          acc[$2.to_i] ||= {}
          acc[$2.to_i][$1.to_s.to_sym] = v
        end

        acc
      end
    end

    # Parses the forwarded ports out of the VM info output and returns
    # it in a hash.
    def forwarded_ports(info, slot)
      seen = false
      info.inject({}) do |acc, data|
        k,v = data

        seen = true if k == "nic#{slot}"
        if seen && k =~ /^Forwarding\((\d+)\)$/
          keys = [:name, :protocol, :hostip, :hostport, :guestip, :guestport]
          v = v.split(",")

          temp = {}
          keys.each_with_index do |key, i|
            temp[key] = v[i]
          end

          acc[temp.delete(:name)] = temp
        end

        acc
      end
    end
  end
end
