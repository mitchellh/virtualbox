module VirtualBox
  module COM
    module Interface
      class BIOSBootMenuMode < AbstractEnum
        map [:disabled, :menu_only, :message_and_menu]
      end
    end
  end
end