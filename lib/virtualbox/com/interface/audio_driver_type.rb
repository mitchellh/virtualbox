module VirtualBox
  module COM
    module Interface
      class AudioDriverType < AbstractEnum
        map [:null, :winmm, :oss, :alsa, :direct_sound, :core_audio, :mmpm, :pulse, :sol_audio]
      end
    end
  end
end