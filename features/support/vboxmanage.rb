class VBoxManage
  class << self
    def command(*args)
      args = args.dup.flatten
      args.unshift("-q")
      "VBoxManage #{args.join(" ")}"
    end

    def execute(*args)
      `#{command(*args)}`.chomp
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
      output = execute("showvminfo", name, "--machinereadable")

      output.split("\n").inject({}) do |acc, line|
        if line =~ /^"?(.+?)"?=(.+?)$/
          key = $1.to_s
          value = $2.to_s
          value = $1.to_s if value =~ /^"(.*?)"$/
          acc[key] = value
        end

        acc
      end
    end
  end
end
