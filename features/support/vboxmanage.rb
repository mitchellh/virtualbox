class VBoxManage
  @@executable = 'VBoxManage'

  class << self
    def execute(*args)
      `#{@@executable} #{args.join(" ")}`.chomp
    end
  end
end
