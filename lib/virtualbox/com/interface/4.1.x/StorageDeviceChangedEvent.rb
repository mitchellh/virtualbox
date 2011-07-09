module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class StorageDeviceChangedEvent < AbstractInterface
          IID = "8a5c2dce-e341-49d4-afce-c95979f7d70c"

          property :storage_device, :MediumAttachment, :readonly => true
          property :removed, T_BOOL, readonly => true
        end
      end
    end
  end
end
