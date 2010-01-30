module VirtualBox
  # Used by the rest of the virtualbox library to call shell commands.
  # It also can be used to change the path for your VBoxManage program.
  #
  # # Changing VBoxManage Path
  #
  # The rest of the library won't work without a proper path to VBoxManage,
  # so it is crucial to set this properly right away. By default its set
  # to `VBoxManage` which assumes that it is in your `PATH`.
  #
  #     VirtualBox::Command.vboxmanage = "/opt/local/bin/VBoxManage"
  #
  class Command
    @@vboxmanage = "VBoxManage"

    class <<self
      # Returns true if the last run command was a success. Obviously this
      # will introduce all sorts of thread-safe problems. Those will have to
      # be addressed another time.
      def success?
        $?.to_i == 0
      end

      # Sets the path to VBoxManage, which is required for this gem to
      # work.
      def vboxmanage=(path)
        @@vboxmanage = path
      end

      # Runs a VBoxManage command and returns the output.
      def vboxmanage(command)
        result = execute("#{@@vboxmanage} #{command}")
        raise Exceptions::CommandFailedException.new(result) if !Command.success?
        result
      end

      # Runs a command and returns a boolean result showing
      # if the command ran successfully or not based on the
      # exit code.
      def test(command)
        execute(command)
        success?
      end

      # Runs a command and returns the STDOUT result. The reason this is
      # a method at the moment is because in the future we may want to
      # change the way commands are run (replace the backticks), plus it
      # makes testing easier.
      def execute(command)
        `#{command}`
      end

      # Shell escapes a string. This is almost a direct copy/paste from
      # the ruby mailing list. I'm not sure how well it works but so far
      # it hasn't failed!
      def shell_escape(str)
        str.to_s.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/n, '\\').
                 gsub(/\n/, "'\n'").
                 sub(/^$/, "''")
      end
    end
  end
end