Then /the number of storage controllers should match/ do
  @relationship.length.should == VBoxManage.storage_controllers(@output).length
end

Then /the storage controller properties should match/ do
  controllers = VBoxManage.storage_controllers(@output)

  @relationship.each do |sc|
    controller = controllers[sc.name]
    controller.should_not be_nil

    STORAGE_MAPPINGS.each do |k,v|
      value = sc.send(k).to_s.downcase.gsub("_", "")
      value.should == controller[v.to_sym].downcase
    end
  end
end
