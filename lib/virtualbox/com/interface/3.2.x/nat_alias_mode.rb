module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class NATAliasMode < AbstractEnum
          map [:null, :alias_log, :alias_proxy_only, :null, :alias_use_same_ports]
        end
      end
    end
  end
end