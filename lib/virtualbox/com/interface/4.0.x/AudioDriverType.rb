module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class AudioDriverType < AbstractEnum
          map [:null, :winmm, :oss, :alsa, :direct_sound, :core_audio, :mmpm, :pulse, :sol_audio]
        end
      end
    end
  end
end