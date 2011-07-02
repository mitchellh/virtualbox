require 'virtualbox/ext/glob_loader'

module VirtualBox
  module COM
    WSTRING = :unicode_string
    T_INT32 = :int
    T_INT64 = :long
    T_ULONG = :ulong
    T_UINT8 = :uchar
    T_UINT16 = :ushort
    T_UINT32 = :uint
    T_UINT64 = :ulong
    T_BOOL = :char
  end
end

# The com directory of the gem
comdir = File.join(File.dirname(__FILE__), 'com')

# Require the abstract interface first then glob load all
# of the interfaces
require File.expand_path("abstract_interface", comdir)
require File.expand_path("abstract_enum", comdir)
VirtualBox::GlobLoader.glob_require(File.join(comdir, "interface"))
VirtualBox::GlobLoader.glob_require(comdir, %w{base_interface abstract_interface abstract_implementer util ffi/interface ffi/util implementer/base})
