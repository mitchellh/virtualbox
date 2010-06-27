Given /the global object/ do
  @model = VirtualBox::Global.global(true)
end

When /I read the media "(.+?)"/ do |property|
  @media = property.gsub(" ", "_").to_sym
  @value = @model.media.send(@media)
end

Then /I should get a matching length for "vms"/ do
  output = VBoxManage.execute("list", "vms")
  @value.length.should == output.split("\n").length
end

Then /I should get a matching length of media items/ do
  mapping = {
    :hard_drives => "hdds",
    :dvds => "dvds",
    :floppies => "floppies"
  }

  output = VBoxManage.execute("list", mapping[@media])
  count = output.split("\n").inject(0) do |acc, line|
    acc += 1 if line =~ /^UUID:/
    acc
  end

  @value.length.should == count
end
