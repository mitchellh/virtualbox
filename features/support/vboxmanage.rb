module VBoxManage
  def vboxmanage_output
    combined_output.chomp
  end

  def vboxmanage(*args)
    args = args.dup
    args.unshift("-q")
    "VBoxManage #{args.join(" ")}"
  end

  def vboxmanage_execute(*args)
    `#{vboxmanage(*args)}`.chomp
  end
end

# Include this so steps can use it
World(VBoxManage)
