module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class Appliance < AbstractInterface
          IID = "e3ba9ab9-ac2c-4266-8bd2-91c4bf721ceb"

          property :path, WSTRING, :readonly => true
          property :disks, [WSTRING], :readonly => true
          property :virtual_system_descriptions, [:VirtualSystemDescription], :readonly => true
          property :machines, [WSTRING], :readonly => true

          function :read, :Progress, [WSTRING]
          function :interpret, nil, []
          function :import_machines, :Progress, []
          function :create_vfs_explorer, :VFSExplorer, [WSTRING]
          function :write, :Progress, [WSTRING, T_BOOL, WSTRING]
          function :get_warnings, [WSTRING], []
        end
      end
    end
  end
end
