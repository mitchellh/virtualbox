Then /the number of storage controllers should match/ do
  @relationship.length.should == VBoxManage.storage_controllers(@output).length
end

Then /the storage controller properties should match/ do
  controllers = VBoxManage.storage_controllers(@output)

  @relationship.each do |sc|
    controller = controllers[sc.name]
    controller.should_not be_nil

    test_mappings(STORAGE_MAPPINGS, sc, controller) do |value, output|
      [value.to_s.downcase.gsub("_",""), output.downcase]
    end
  end
end
