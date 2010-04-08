module VirtualBox
  module COM
    module Implementer
      # A "nil" implementer which doesn't actually do anything. This is used in
      # tests.
      class Nil < AbstractImplementer
      end
    end
  end
end