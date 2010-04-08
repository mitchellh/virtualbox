module VirtualBox
  module COM
    module Interface
      class MediumState < AbstractEnum
        map [:not_created, :created, :locked_read, :locked_write, :inaccessible, :creating, :deleting]
      end
    end
  end
end