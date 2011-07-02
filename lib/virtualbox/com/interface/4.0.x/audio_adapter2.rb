module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class AudioAdapter < AbstractInterface
          IID = "921873db-5f3f-4b69-91f9-7be9e535a2cb"

          property :enabled, T_BOOL
          property :audio_controller, :AudioControllerType
          property :audio_driver, :AudioDriverType
        end
      end
    end
  end
end