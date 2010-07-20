module VirtualBox
  module COM
    class MSCOMInterface < BaseInterface
      # The VirtualBox and Session interfaces, both of which are extremely
      # important in interfacing with the VirtualBox API. Once these have been
      # initialized, all other parts of the API can be accessed via these
      # instances.
      attr_reader :virtualbox
      attr_reader :session

      def initialize
        super
        initialize_mscom
      end

      def initialize_mscom
        require 'win32ole'

        interface_dir = File.expand_path(File.join(File.dirname(__FILE__), "interface"))
        Dir[File.join(interface_dir, "*")].each do |f|
          p "Checking: #{f}"
          return if File.directory?(f) && initialize_for_version(File.basename(f))
        end
      end

      def initialize_for_version(version)
        COM::Util.set_interface_version(version)

        @virtualbox = COM::Util.versioned_interface(:VirtualBox).new(Implementer::MSCOM, self, WIN32OLE.new("VirtualBox.VirtualBox"))
        @session = COM::Util.versioned_interface(:Session).new(Implementer::MSCOM, self, WIN32OLE.new("VirtualBox.Session"))

        vb_version = @virtualbox.version

        # Check if they match or not.
        return false if vb_version.length == version.length
        (0...(version.length)).each do |i|
          p "Checking: #{version[i,1]} to #{vb_version[i,1]}"
          next if version[i,1] == "x"
          return false if version[i,1] != vb_version[i,1]
        end

        true
      end
    end
  end
end
