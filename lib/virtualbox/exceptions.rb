module VirtualBox
  # Gem specific exceptions will reside under this namespace for easy
  # documentation and searching.
  module Exceptions
    class Exception < ::Exception; end

    class InvalidObjectException < Exception; end
    class InvalidRelationshipObjectException < Exception; end
    class NonSettableRelationshipException < Exception; end
    class NoParentException < Exception; end
  end
end