Given /the forwarded ports are cleared/ do
  VBoxManage.network_adapters(@output).each_with_index do |obj, i|
    VBoxManage.forwarded_ports(@output, i+1).each do |name, data|
      VBoxManage.execute("modifyvm", @name, "--natpf#{i+1}", "delete", name)
    end
  end
end

Given /I read the adapter in slot "(.+?)"$/ do |slot|
  @slot = slot.to_i
  @adapter = VBoxManage.network_adapters(@output)[slot.to_i]
  @adapter.should_not be_nil

  @relationship = @model.network_adapters[slot.to_i - 1].nat_driver
end

Given /I create a forwarded port named "(.+?)" from "(.+?)" to "(.+?)" via VBoxManage/ do |name, guest, host|
  fp_string = "#{name},tcp,,#{host},,#{guest}"
  VBoxManage.execute("modifyvm", @name, "--natpf#{@slot}", fp_string)
end

When /I create a forwarded port named "(.+?)" from "(.+?)" to "(.+?)"$/ do |name, guest, host|
  @object = VirtualBox::NATForwardedPort.new
  @object.name = name
  @object.guestport = guest.to_i
  @object.hostport = host.to_i

  @relationship.forwarded_ports << @object
end

Then /the NAT network should exist/ do
  # Temporary until we find something to really test
  @relationship.should_not be_nil
end

Then /the forwarded port "(.+?)" should exist/ do |name|
  ports = VBoxManage.forwarded_ports(@output, @slot)
  ports.should have_key(name)
end

Then /the forwarded ports should match/ do
  ports = VBoxManage.forwarded_ports(@output, @slot)

  @relationship.forwarded_ports.length.should == ports.length
  @relationship.forwarded_ports.each do |fp|
    port = ports[fp.name]
    port.should_not be_nil

    test_mappings(FORWARDED_PORT_MAPPINGS, fp, port)
  end
end
