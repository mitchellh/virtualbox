module VirtualBox
  # Represents a DVD image stored by VirtualBox. These DVD images can be
  # mounted onto virtual machines. Because DVD just inherits from {Medium},
  # it also inherits all methods and attributes which are on {Medium}. For more
  # attributes, the ability to destroy, etc, please view {Medium}.
  #
  # # Finding all DVDs
  #
  # The only method at the moment of finding DVDs is to use {DVD.all}, which
  # returns an array of {DVD}s.
  #
  #     DVD.all
  #
  class DVD < Medium
    class << self
      # Returns an array of all available DVDs as DVD objects
      def all
        Global.global.media.dvds
      end

      # Override of {Medium.device_type}.
      def device_type
        :dvd
      end
    end
  end
end
