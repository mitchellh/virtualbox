module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class MachineState < AbstractEnum
          map [:null, :powered_off, :saved, :teleported, :aborted, :running, :paused, :stuck,
                :teleporting, :live_snapshotting, :starting, :stopping, :saving, :restoring,
                :teleporting_paused_vm, :teleporting_in, :restoring_snapshot, :deleting_snapshot,
                :setting_up]
        end
      end
    end
  end
end
