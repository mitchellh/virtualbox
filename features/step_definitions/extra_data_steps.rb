Given /the extra data of "(.+?)"/ do |name|
  @output = vboxmanage_execute("getextradata", name, "enumerate")
end

Then /all the extra data should match/ do
  data = @output.split("\n").inject({}) do |acc, line|
    acc[$1.to_s] = $2.to_s if line =~ /^Key: (.+?), Value: (.+?)$/
    acc
  end

  @relationship.length.should == data.length
  data.each do |k,v|
    @relationship[k].should == v
  end
end
