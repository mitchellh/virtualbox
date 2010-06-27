When /I find a VM identified by "(.+?)"/ do |name|
  @output = VBoxManage.vm_info(name)
  @model = VirtualBox::VM.find(name)
end

Then /the VM should not exist/ do
  @output.should be_empty
  @model.should be_nil
end

Then /the VM should exist/ do
  @output.should have_key("UUID")
  @model.should_not be_nil
end

Then /the properties should match/ do
  VM_MAPPINGS.each do |model_key, output_key|
    value = @model.send(model_key)

    if [TrueClass, FalseClass].include?(value.class)
      # Convert true/false to VirtualBox-style string boolean values
      value = value ? "on" : "off"
    end

    value.to_s.should == @output[output_key]
  end
end
