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

    # Parses the snapshots out of the VM info output and returns it in
    # a hash.
    def snapshots(info)
      info.inject({}) do |acc, data|
        k,v = data

        if k =~ /^Snapshot(.+?)(-(.+?))?$/
          current = { $1.to_s.downcase.to_sym => v }

          if $3
            # This is a child snapshot
            keys = $3.to_s.split("-").map do |key|
              key.to_i - 1
            end
            final = keys.pop

            location = acc
            keys.each { |index| location = location[:children][index.to_i] }

            parent = location
            location = location[:children]
            location[final] ||= {}
            location[final].merge!(current)
            location[final][:parent] = parent
            location[final][:children] ||= []
          else
            acc ||= {}
            acc.merge!(current)
            acc[:children] ||= []
          end
        end

        acc
      end
    end

    # Gets the current snapshot.
    def current_snapshot(info)
      seen = false
      uuid = nil
      VBoxManage.execute("showvminfo", info["UUID"]).split("\n").each do |line|
        seen = true if line =~ /^Snapshots:/
        uuid = $2.to_s if seen && line =~ /Name:\s+(.+?)\s+\(UUID:\s+(.+?)\)\s+\*/
      end

      # The recursive sub-method which finds a snapshot by UUID
      finder = lambda do |snapshot|
        return snapshot if snapshot[:uuid] == uuid

        snapshot[:children].find do |child|
          finder.call(child)
        end
      end

      finder.call(snapshots(info))
    end
  end
end
