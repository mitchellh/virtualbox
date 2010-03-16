module VirtualBox
  class Platform
    class <<self
      def mac?
        platform.include?("darwin")
      end

      def windows?
        platform.include?("mswin") || platform.include?("mingw")
      end

      def linux?
        platform.include?("linux")
      end

      def platform
        RUBY_PLATFORM.downcase
      end
    end
  end
end