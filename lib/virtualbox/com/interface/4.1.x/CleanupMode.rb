module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class CleanupMode < AbstractEnum
          map [:null, :unregister_only, :detach_all_return_none,
               :detach_all_return_hard_disks_only, :full]
        end
      end
    end
  end
end
