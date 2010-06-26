When /I try to read the virtualbox "(.+?)"/ do |item|
  @result = VirtualBox.send(item)
end

Then /the result should be "(.+?)"/ do |result|
  @result.to_s.should == result
end
