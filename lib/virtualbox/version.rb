module VirtualBox
  VERSION = "0.8.2.dev"

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
    # This string is cached since the version typically doesn't change
    # during runtime. If you must refresh the version, send the boolean
    # `true` as the first parameter.
    def version(refresh=false)
      @_version = Lib.lib.virtualbox.version if @_version.nil? || refresh
      @_version
    rescue Exception
      nil
    end

    # Returns the revision string of the VirtualBox installed, ex. "51742"
    # This string is cached since the revision doesn't typically change during
    # runtime. If you must refresh the version, send the boolean `true` as the
    # first parameter.
    def revision(refresh=false)
      @_revision = Lib.lib.virtualbox.revision.to_s if @_revision.nil? || refresh
      @_revision
    end
  end
end
