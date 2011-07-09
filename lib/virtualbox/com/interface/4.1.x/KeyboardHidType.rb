module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class KeyboardHidType < AbstractEnum
          map [:null, :none, :ps2_keyboard, :usb_keyboard, :combo_keyboard]
        end
      end
    end
  end
end
