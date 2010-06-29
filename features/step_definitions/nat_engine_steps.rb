Given /I read the adapter in slot "(.+?)"$/ do |slot|
  @adapter = VBoxManage.network_adapters(@output)[slot.to_i]
  @adapter.should_not be_nil
end

Then /the NAT network should exist/ do
  # Temporary until we find something to really test
  @relationship.should_not be_nil
end
