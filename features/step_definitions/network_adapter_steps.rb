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
