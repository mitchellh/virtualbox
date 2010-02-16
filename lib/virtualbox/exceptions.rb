module VirtualBox
  # Gem specific exceptions will reside under this namespace for easy
  # documentation and searching.
  module Exceptions
    class Exception < ::Exception; end

    class CommandFailedException < Exception; end
    class ConfigurationException < Exception; end
    class InvalidRelationshipObjectException < Exception; end
    class NonSettableRelationshipException < Exception; end
    class ValidationFailedException < Exception; end
  end
end