module VirtualBox
  # Gem specific exceptions will reside under this namespace for easy
  # documentation and searching.
  module Exceptions
    class Exception < ::Exception; end

    class NoParentException < Exception; end
    class NonSettableRelationshipException < Exception; end
  end
end