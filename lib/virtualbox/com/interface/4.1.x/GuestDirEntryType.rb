module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class GuestDirEntryType < AbstractEnum
          map :unknown   => 0,
              :directory => 4,
              :file      => 10,
              :symlink   => 12
        end
      end
    end
  end
end
