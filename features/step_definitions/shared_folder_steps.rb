Given /I add a shared folder "(.+?)" with path "(.+?)" via VBoxManage/ do |name,hostpath|
  VBoxManage.execute("sharedfolder", "add", @name,
                     "--name", name,
                     "--hostpath", hostpath)
end

Given /I delete the shared folder "(.+?)" via VBoxManage/ do |name|
  VBoxManage.execute("sharedfolder", "remove", @name,
                     "--name", name)
end

Given /a shared folder "(.+?)" exists/ do |name|
  folders = VBoxManage.shared_folders(@output)

  if !folders.keys.include?(name)
    Given %Q[I add a shared folder "#{name}" with path "/#{name}" via VBoxManage]
    Given %Q[I reload the VM]
    Given %Q[the "shared_folders" relationship]
  end
end

Given /no shared folder "(.+?)" exists/ do |name|
  folders = VBoxManage.shared_folders(@output)

  if folders.keys.include?(name)
    Given %Q[I delete the shared folder "#{name}" via VBoxManage]
    Given %Q[I reload the VM]
    Given %Q[the "shared_folders" relationship]
  end
end

When /I create a new shared folder "(.+?)" with path "(.+?)"/ do |name,hostpath|
  @new_record = VirtualBox::SharedFolder.new
  @new_record.name = name
  @new_record.host_path = hostpath
end

When /I delete the shared folder "(.+?)"$/ do |name|
  @relationship.each do |sf|
    sf.destroy if sf.name == name
  end
end

Then /the shared folder "(.+?)" should not exist/ do |name|
  VBoxManage.shared_folders(@output).keys.should_not include(name)
end

Then /the shared folder properties should match/ do
  folders = VBoxManage.shared_folders(@output)

  @relationship.length.should == folders.length

  @relationship.each do |sf|
    folder = folders[sf.name]

    SHARED_FOLDER_MAPPINGS.each do |k,v|
      value = sf.send(k)
      value.should == folder[v.to_sym]
    end
  end
end
