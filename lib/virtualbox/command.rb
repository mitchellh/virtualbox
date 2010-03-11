module VirtualBox
  def self.version
    Command.version
  end

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
      # Returns a string of the version of VirtualBox installed, or nil if
      # it can't detect VirtualBox.
      #
      # @return [String]
      def version
        result = execute("#{@@vboxmanage} --version")
        return nil unless Command.success?
        result.chomp
      end

      # Reads the XML file and returns a Nokogiri document. Reads the XML data
      # from the specified file and returns a Nokogiri document.
      #
      # @param [String] File name.
      # @return [Nokogiri::XML::Document]
      def parse_xml(filename)
        f = File.open(filename, "r")
        result = Nokogiri::XML(f)
        f.close

        result
      end

      # Returns true if the last run command was a success. Obviously this
      # will introduce all sorts of thread-safe problems. Those will have to
      # be addressed another time.
      def success?
        $?.to_i == 0
      end

      # Sets the path to VBoxManage, which is required for this gem to
      # work.
      #
      # @param [String] Full path to `VBoxManage`.
      def vboxmanage=(path)
        @@vboxmanage = path
      end

      # Runs a VBoxManage command and returns the output. This method will automatically
      # shell escape all args passed to it. There is no way to avoid this at the moment
      # (since it hasn't been necessary to). This will raise an {Exceptions::CommandFailedException}
      # if the exit status of the command is nonzero. It is up to the caller to figure
      # out how to handle this; there is no way to suppress it via a parameter to this
      # call.
      #
      # Upon success, {vboxmanage} returns the stdout output from the command.
      #
      # @return [String] The data from stdout of the command.
      def vboxmanage(*args)
        args.collect! { |arg| shell_escape(arg.to_s) }
        result = execute("#{@@vboxmanage} -q #{args.join(" ")}")
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
        if RUBY_PLATFORM.downcase.include?("mswin")
          # Special case for windows. This is probably not 100% bullet proof
          # but it gets the job done until we find trouble
          return "\"#{str}\"" if str =~ /\s/
        end

        str.to_s.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/n, '\\').
                 gsub(/\n/, "'\n'").
                 sub(/^$/, "''")
      end
    end
  end
end