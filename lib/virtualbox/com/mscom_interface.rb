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

        # TODO: Dynamic version finding
        COM::Util.set_interface_version("3.1.x")

        @virtualbox = COM::Util.versioned_interface(:VirtualBox).new(Implementer::MSCOM, self, WIN32OLE.new("VirtualBox.VirtualBox"))
        @session = COM::Util.versioned_interface(:Session).new(Implementer::MSCOM, self, WIN32OLE.new("VirtualBox.Session"))
      end
    end
  end
end
