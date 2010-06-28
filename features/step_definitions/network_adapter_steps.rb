Given /the adapters are reset/ do
  VBoxManage.network_adapters(@output).each_with_index do |obj, i|
    VBoxManage.execute("modifyvm", @name, "--nic#{i+1}", "none")
  end
end

Given /the adapter in slot "(.+?)" is type "(.+?)"/ do |slot, type|
  VBoxManage.execute("modifyvm", @name, "--nic#{slot}", type)
end

Given /the following adapters are set:/ do |table|
  table.hashes.each do |hash|
    Given %Q[the adapter in slot "#{hash["slot"]}" is type "#{hash["type"]}"]
  end
end

When /I update the adapter in slot "(.+?)"/ do |slot|
  adapter = @relationship.find { |na| na.slot == (slot.to_i - 1) }
  adapter.should_not be_nil

  @model = adapter
end

Then /the network adapter properties should match/ do
  adapters = VBoxManage.network_adapters(@output)
  @relationship.length.should == adapters.length

  @relationship.each do |na|
    adapter = adapters[na.slot + 1]
    adapter.should_not be_nil

    if na.enabled?
      test_mappings(NETWORK_ADAPTER_MAPPINGS, na, adapter)
    else
      adapter[:type].should == "none"
    end
  end
end
