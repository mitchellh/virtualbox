module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class PointingHidType < AbstractEnum
          map [:null, :none, :ps2_mouse, :usb_mouse, :usb_tablet, :combo_mouse]
        end
      end
    end
  end
end