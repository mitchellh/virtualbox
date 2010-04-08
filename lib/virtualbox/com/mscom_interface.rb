module VirtualBox
  module COM
    class MSCOMInterface
      # The VirtualBox and Session interfaces, both of which are extremely
      # important in interfacing with the VirtualBox API. Once these have been
      # initialized, all other parts of the API can be accessed via these
      # instances.
      attr_reader :virtualbox
      attr_reader :session

      def initialize
        initialize_mscom
      end

      def initialize_mscom
        require 'win32ole'
        @virtualbox = Interface::VirtualBox.new(Implementer::MSCOM, self, WIN32OLE.new("VirtualBox.VirtualBox"))
        @session = Interface::Session.new(Implementer::MSCOM, self, WIN32OLE.new("VirtualBox.Session"))
      end
    end
  end
end