require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SharedFolderTest < Test::Unit::TestCase
  setup do
    @data = {
      :sharedfoldernamemachinemapping1 => "foofolder",
      :sharedfolderpathmachinemapping1 => "/foo",
      :sharedfoldernamemachinemapping2 => "barfolder",
      :sharedfolderpathmachinemapping2 => "/bar"
    }

    @caller = mock("caller")
    @caller.stubs(:name).returns("foo")

    VirtualBox::Command.stubs(:execute)
  end

  context "validations" do
    setup do
      @sf = VirtualBox::SharedFolder.new
      @sf.name = "foo"
      @sf.hostpath = "bar"
      @sf.added_to_relationship(@caller)
    end

    should "be valid with all fields" do
      assert @sf.valid?
    end

    should "be invalid with no name" do
      @sf.name = nil
      assert !@sf.valid?
    end

    should "be invalid with no hostpath" do
      @sf.hostpath = nil
      assert !@sf.valid?
    end

    should "be invalid if not in a relationship" do
      @sf.write_attribute(:parent, nil)
      assert !@sf.valid?
    end
  end

  context "saving an existing shared folder" do
    setup do
      @value = VirtualBox::SharedFolder.populate_relationship(@caller, @data)
      @value = @value[0]
      @value.name = "different"
      assert @value.changed?
    end

    should "first destroy the shared folder then recreate it" do
      seq = sequence("create_seq")
      @value.expects(:destroy).in_sequence(seq)
      VirtualBox::Command.expects(:vboxmanage).in_sequence(seq)
      assert @value.save
    end

    should "call destroy with raise errors if set" do
      @value.expects(:destroy).with(true).once
      assert @value.save(true)
    end
  end

  context "creating a new shared folder" do
    setup do
      @sf = VirtualBox::SharedFolder.new
      @sf.name = "foo"
      @sf.hostpath = "bar"
    end

    should "return false and not call vboxmanage if invalid" do
      VirtualBox::Command.expects(:vboxmanage).never
      @sf.expects(:valid?).returns(false)
      assert !@sf.save
    end

    should "raise a ValidationFailedException if invalid and raise_errors is true" do
      @sf.expects(:valid?).returns(false)
      assert_raises(VirtualBox::Exceptions::ValidationFailedException) {
        @sf.save(true)
      }
    end

    context "has a parent" do
      setup do
        @sf.added_to_relationship(@caller)
        VirtualBox::Command.stubs(:vboxmanage)
      end

      should "not call destroy since its a new record" do
        @sf.expects(:destroy).never
        assert @sf.save
      end

      should "call the proper vboxcommand" do
        VirtualBox::Command.expects(:vboxmanage).with("sharedfolder add #{@caller.name} --name #{@sf.name} --hostpath #{@sf.hostpath}")
        assert @sf.save
      end

      should "return false if the command failed" do
        VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
        assert !@sf.save
      end

      should "return true if the command was a success" do
        assert @sf.save
      end

      should "raise an exception if true sent to save and error occured" do
        VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
        assert_raises(VirtualBox::Exceptions::CommandFailedException) {
          @sf.save(true)
        }
      end

      should "not be a new record after saving" do
        assert @sf.new_record?
        assert @sf.save
        assert !@sf.new_record?
      end

      should "not be changed after saving" do
        assert @sf.changed?
        assert @sf.save
        assert !@sf.changed?
      end
    end
  end

  context "constructor" do
    should "call initialize_for_relationship if 3 args are given" do
      VirtualBox::SharedFolder.any_instance.expects(:initialize_for_relationship).with(1,2,3).once
      VirtualBox::SharedFolder.new(1,2,3)
    end

    should "raise a NoMethodError if anything other than 0,1,or 3 arguments" do
      2.upto(9) do |i|
        next if i == 3
        args = Array.new(i, "A")

        assert_raises(NoMethodError) {
          VirtualBox::SharedFolder.new(*args)
        }
      end
    end

    should "populate from a hash if one argument is given" do
      VirtualBox::SharedFolder.any_instance.expects(:initialize_for_data).with("HI").once
      VirtualBox::SharedFolder.new("HI")
    end

    context "initializing from data" do
      setup do
        @sf = VirtualBox::SharedFolder.new({:name => "foo", :hostpath => "bar"})
      end

      should "allow the use of :name and :hostpath in the hash" do
        assert_equal "foo", @sf.name
        assert_equal "bar", @sf.hostpath
      end

      should "keep the record new" do
        assert @sf.new_record?
      end
    end
  end

  context "destroying" do
    setup do
      @value = VirtualBox::SharedFolder.populate_relationship(@caller, @data)
      @value = @value[0]
    end

    should "call the proper command" do
      VirtualBox::Command.expects(:vboxmanage).with("sharedfolder remove #{@caller.name} --name #{@value.name}").once
      assert @value.destroy
    end

    should "shell escape VM name and storage controller name" do
      shell_seq = sequence("shell_seq")
      VirtualBox::Command.expects(:shell_escape).with(@caller.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:shell_escape).with(@value.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:vboxmanage).in_sequence(shell_seq)
      assert @value.destroy
    end

    should "return false if destroy failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@value.destroy
    end

    should "raise an exception if destroy failed and an error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @value.destroy(true)
      }
    end

    should "use the old name if it was changed" do
      @value.name = "DIFFERENT"
      shell_seq = sequence("shell_seq")
      VirtualBox::Command.expects(:shell_escape).with(@caller.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:shell_escape).with(@value.name_was).in_sequence(shell_seq)
      VirtualBox::Command.expects(:vboxmanage).in_sequence(shell_seq)
      assert @value.destroy
    end
  end

  context "populating relationships" do
    setup do
      @value = VirtualBox::SharedFolder.populate_relationship(@caller, @data)
    end

    should "be a 'collection'" do
      assert @value.is_a?(VirtualBox::Proxies::Collection)
    end

    should "create the correct amount of objects" do
      assert_equal 2, @value.length
    end

    should "parse the proper data" do
      value = @value[0]
      assert_equal "foofolder", value.name
      assert_equal "/foo", value.hostpath

      value = @value[1]
      assert_equal "barfolder", value.name
      assert_equal "/bar", value.hostpath
    end
  end
end