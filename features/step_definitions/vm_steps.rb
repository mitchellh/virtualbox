When /I find a VM identified by "(.+?)"/ do |name|
  @output = VBoxManage.execute("showvminfo", name)
  @object = VirtualBox::VM.find(name)
end

Then /the VM should not exist/ do
  @output.should =~ /^ERROR: Could not find a registered machine/
  @object.should be_nil
end

Then /the VM should exist/ do
  @output.should =~ /^UUID: /
  @object.should_not be_nil
end
