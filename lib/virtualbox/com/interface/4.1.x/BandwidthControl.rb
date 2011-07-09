module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class BandwidthControl < AbstractInterface
          IID_STR = "D0A24DB0-F756-11DF-98CF-0800200C9A66"

          property :num_groups, T_UINT32, :readonly => true

          function :create_bandwidth_group, nil, [WSTRING, :BandwidthGroupType, T_UINT32]
          function :delete_bandwidth_group, nil, [WSTRING]
          function :get_bandwidth_group, :BandwidthGroup, [WSTRING]
          function :get_all_bandwidth_groups, [:BandwidthGroup], []
        end
      end
    end
  end
end
