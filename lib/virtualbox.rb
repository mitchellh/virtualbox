# Load the glob loader, which will handle the loading of all the other files
libdir = File.join(File.dirname(__FILE__), "virtualbox")
require File.expand_path("ext/glob_loader", libdir)

# Load them up
VirtualBox::GlobLoader.glob_require(libdir, %w{ext/logger ext/platform ext/subclass_listing ext/byte_normalizer com abstract_model medium})

# Setup the top-level module methods
module VirtualBox
  extend Version
end
