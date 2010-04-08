module VirtualBox
  module COM
    module Interface
      class SharedFolder < AbstractInterface
        IID = "64637bb2-9e17-471c-b8f3-f8968dd9884e"

        property :name, WSTRING, :readonly => true
        property :host_path, WSTRING, :readonly => true
        property :accessible, T_BOOL, :readonly => true
        property :writable, T_BOOL, :readonly => true
        property :last_access_error, WSTRING, :readonly => true
      end
    end
  end
end