module VBoxManage
  def vboxmanage_output
    combined_output.chomp
  end
end

# Include this so steps can use it
World(VBoxManage)
