module VirtualBox
  # Gem specific exceptions will reside under this namespace for easy
  # documentation and searching.
  module Exceptions
    class Exception < ::Exception; end

    class NonSettableRelationshipException < Exception; end
    class ValidationFailedException < Exception; end
    class MediumLocationInUseException < Exception; end
    class MediumCreationFailedException < Exception; end
    class MediumNotUpdatableException < Exception; end
    class ReadonlyVMStateException < Exception; end
    class UnsupportedVersionException < Exception; end

    class COMException < Exception
      attr_accessor :data

      def initialize(data={})
        @data = data
        super("Error in API call to #{data[:function]}: #{data[:result_code]}")
      end
    end

    # FFI Exceptions, these exceptions are only raised on *nix machines
    # when some error occurs in the foreign function interface.
    class ObjectNotFoundException < COMException; end
    class InvalidVMStateException < COMException; end
    class VMErrorException < COMException; end
    class FileErrorException < COMException; end
    class SubsystemException < COMException; end
    class PDMException < COMException; end
    class InvalidObjectStateException < COMException; end
    class HostErrorException < COMException; end
    class NotSupportedException < COMException; end
    class XMLErrorException < COMException; end
    class InvalidSessionStateException < COMException; end
    class ObjectInUseException < COMException; end
  end
end
