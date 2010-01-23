module VirtualBox
  class Command
    @@vboxmanage = "VBoxManage"
    
    class <<self
      # Sets the path to VBoxManage, which is required for this gem to
      # work.
      def vboxmanage=(path)
        @@vboxmanage = path
      end
      
      # Runs a VBoxManage command
      def vboxmanage(command)
        execute("#{@@vboxmanage} #{command}")
      end
      
      # Runs a command and returns a boolean result showing
      # if the command ran successfully or not based on the 
      # exit code.
      def test(command)
        execute(command)
        $?.to_i == 0
      end
    
      # Runs a command and returns the STDOUT result. The reason this is
      # a method at the moment is because in the future we may want to 
      # change the way commands are run (replace the backticks), plus it
      # makes testingn easier.
      def execute(command)
        `#{command}`
      end
      
      # Shell escapes a string. Got it from the ruby mailing list. To be
      # honest I'm not sure how well it works.
      def shell_escape(str)
        str.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/n, '\\').
            gsub(/\n/, "'\n'").
            sub(/^$/, "''")
      end
    end
  end
end