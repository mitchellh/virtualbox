module VirtualBox
  module COM
    module Interface
      class MediumVariant < AbstractEnum
        map [:standard, :vmdk_split_2g, :vmdk_stream_optimized, :vmdk_esx, :fixed, :diff]
      end
    end
  end
end