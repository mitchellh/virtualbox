require 'virtualbox/ext/platform'

module VirtualBox
  # Eases the processes of loading specific files then globbing
  # the rest from a specified directory.
  module GlobLoader
    # Glob requires all ruby files in a directory, optionally loading select
    # files initially (since others may depend on them).
    #
    # @param [String] dir The directory to glob
    # @param [Array<String>] initial_files Initial files (relative to `dir`)
    #   to load
    def self.glob_require(dir, initial_files=[])
      # Note: The paths below both are "downcased" because on Windows, some
      # expand to "c:\" and some expand to "C:\" and cause the same file to
      # be loaded twice. Uck.

      require_files = []
      initial_files.each do |file|
        require_files << File.expand_path(file, dir)
      end

      # Glob require the rest
      Dir[File.join(dir, "**", "*.rb")].each do |f|
        require_files << File.expand_path(f)
      end

      # Iterate over the files to require, manipulating them if necessary
      require_files.each do |file|
        file = file.downcase if Platform.windows?
        require file
      end
    end
  end
end
