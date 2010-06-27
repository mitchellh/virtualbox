class VBoxManage
  class << self
    def command(*args)
      args = args.dup
      args.unshift("-q")
      "VBoxManage #{args.join(" ")}"
    end

    def execute(*args)
      `#{command(*args)}`.chomp
    end

    def extra_data(name)
      output = execute("getextradata", name, "enumerate")

      output.split("\n").inject({}) do |acc, line|
        acc[$1.to_s] = $2.to_s if line =~ /^Key: (.+?), Value: (.+?)$/
        acc
      end
    end
  end
end
