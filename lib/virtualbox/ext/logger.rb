require 'logger'

module VirtualBox
  # Provides logger functionality for VirtualBox. This class is available on most
  # VirtualBox classes through mixins. To access the logger, simply call the {logger}
  # method. This returns a standard Ruby logger which can be modified.
  module Logger
    @@logger = nil
    @@logger_output = nil

    # Make the logger available both on a class and instance level
    # once included.
    def self.included(base)
      base.extend self
    end

    # Sets up the output stream for the logger. This should be called before any
    # calls to {logger}. If the logger has already been instantiated, then a new
    # logger will be created on the next call with the new output setup.
    def logger_output=(value)
      @@logger_output = value
      @@logger = nil
    end

    # Accesses the logger. If logger output is specified and this is the first load,
    # then the logger will be properly setup to point to that output. Logging
    # levels should also be set once the logger is created. The logger is a standard
    # Ruby `Logger`.
    #
    # The VirtualBox gem can get very verybose very quickly, so choose a log level
    # which suits the granularity needed.
    #
    # @return [Logger]
    def logger
      @@logger ||= ::Logger.new(@@logger_output)
    end
  end
end