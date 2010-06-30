Given /the snapshots are cleared/ do
  snapshot_map(VBoxManage.snapshots(@output)) do |snapshot|
    VBoxManage.execute("snapshot", @name, "delete", snapshot[:name])
  end
end

Given /the following snapshot tree is created:$/ do |tree|
  tree.hashes.each do |hash|
    restore_parent = lambda do
      VBoxManage.execute("snapshot", @name, "restore", hash["key"])
    end

    begin
      restore_parent.call
    rescue Exception
      VBoxManage.execute("snapshot", @name, "take", hash["key"])
    end

    hash["children"].split(",").each do |child|
      VBoxManage.execute("snapshot", @name, "take", child)
      restore_parent.call
    end
  end
end

Given /the snapshot "(.+?)" is created/ do |name|
  VBoxManage.execute("snapshot", @name, "take", name)
end

When /I find the snapshot named "(.+?)"/ do |name|
  @snapshot = @model.find_snapshot(name)
  @snapshot.should be
end

When /I take a snapshot "(.+?)"/ do |name|
  @model.take_snapshot(name)
end

When /I destroy the snapshot/ do
  @snapshot.destroy
end

Then /the snapshot "(.+?)" should exist/ do |name|
  result = false
  snapshot_map(VBoxManage.snapshots(@output)) do |snapshot|
    result = true if snapshot[:name] == name
  end

  result.should be
end

Then /the snapshot "(.+?)" should not exist/ do |name|
  result = false
  snapshot_map(VBoxManage.snapshots(@output)) do |snapshot|
    result = true if snapshot[:name] == name
  end

  result.should_not be
end

Then /the snapshots should match/ do
  @root = @model.root_snapshot

  match_tester = lambda do |current, expected|
    current.uuid.should == expected[:uuid]
    current.children.length.should == expected[:children].length

    current.children.each_with_index do |current_child, i|
      match_tester.call(current_child, expected[:children][i])
    end
  end

  match_tester.call(@root, VBoxManage.snapshots(@output))
end
