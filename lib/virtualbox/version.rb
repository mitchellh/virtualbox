module VirtualBox
  module Version
    # Returns a boolean denoting whether the current VirtualBox
    # version is supported or not. This will return `false` if the
    # version is invalid, the version is not detected, etc. That means
    # that even if VirtualBox is not installed, this will simply
    # return `false`.
    #
    # @return [Boolean]
    def supported?
      !version.nil?
    end

    # Returns the version string of the VirtualBox installed, ex. "3.1.6"
    def version
      Lib.lib.virtualbox.version
    rescue Exception
      nil
    end

    # Returns the revision string of the VirtualBox installed, ex. "51742"
    def revision
      Lib.lib.virtualbox.revision
    end
  end
end
