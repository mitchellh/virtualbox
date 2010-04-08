module VirtualBox
  module Version
    # Returns the version string of the VirtualBox installed, ex. "3.1.6"
    def version
      Lib.lib.virtualbox.version
    end

    # Returns the revision string of the VirtualBox installed, ex. "51742"
    def revision
      Lib.lib.virtualbox.revision
    end
  end
end