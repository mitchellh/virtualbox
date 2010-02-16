module VirtualBox
  # Represents the VirtualBox main configuration file (VirtualBox.xml)
  # which VirtualBox uses to keep track of all known virtual machines
  # and images.
  class Global < AbstractModel
    # The path to the global VirtualBox XML configuration file. This is
    # entirely system dependent and can be set with {vboxconfig=}. The default
    # is guessed based on the platform.
    #
    # TODO: Windows
    @@vboxconfig = if RUBY_PLATFORM.downcase.include?("darwin")
      "~/Library/VirtualBox/VirtualBox.xml"
    elsif RUBY_PLATFORM.downcase.include?("linux")
      "~/.VirtualBox/VirtualBox.xml"
    else
      "Unknown"
    end

    relationship :vms, VM, :lazy => true
    relationship :media, Media
    relationship :extra_data, ExtraData

    @@global_data = nil

    class <<self
      def global(reload = false)
        if !@@global_data || reload || reload?
          @@global_data = new(config)
          reloaded!
        end

        @@global_data
      end

      # Sets the path to the VirtualBox.xml file. This file should already
      # exist. VirtualBox itself manages this file, not this library.
      #
      # @param [String] Full path to the VirtualBox.xml file
      def vboxconfig=(value)
        @@vboxconfig = value
      end

      # Returns the XML document of the configuration. This will raise an
      # {Exceptions::ConfigurationException} if the vboxconfig file doesn't
      # exist.
      #
      # @return [Nokogiri::XML::Document]
      def config
        raise Exceptions::ConfigurationException.new("The path to the global VirtualBox config must be set. See Global.vboxconfig=") unless File.exist?(@@vboxconfig)
        Command.parse_xml(File.expand_path(@@vboxconfig))
      end

      # Expands path relative to the configuration file.
      #
      # @return [String]
      def expand_path(path)
        File.expand_path(path, File.dirname(@@vboxconfig))
      end
    end

    def initialize(document)
      @document = document
      populate_attributes(@document)
    end

    def load_relationship(name)
      populate_relationship(:vms, @document)
    end
  end
end