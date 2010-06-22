module VirtualBox
  class AbstractModel
    module VersionMatcher
      # Asserts that two versions match. Otherwise raises an
      # exception.
      def assert_version_match(req, cur)
        if !version_match?(req, cur)
          message = "Required version: #{req}; Current: #{cur}"
          raise Exceptions::UnsupportedVersionException.new(message)
        end
      end

      # Checks if a given version requirement matches the current
      # version.
      #
      # @return [Boolean]
      def version_match?(requirement, current)
        split_version(requirement) == split_version(current)
      end

      # Splits a version string into a two-item array with the parts
      # of the version, respectively. If the version has more than two
      # parts, the rest are ignored.
      #
      # @param [String] version
      # @return [Array]
      def split_version(version)
        version.split(/\./)[0,2]
      rescue Exception
        []
      end
    end
  end
end

