# Testing VBoxManage -v output
When /I try to read the virtualbox "(.+?)"/ do |item|
  @key = item.to_sym
  @result = VirtualBox.send(item)
end

Then /the result should match version output/ do
  data = VBoxManage.execute("-v").split("r")
  results = {
    :version => data[0],
    :revision => data[1],
    :supported? => !!data
  }

  @result.should == results[@key]
end

