# Before everything, load virtualbox, of course
require 'spec'
require File.join(File.dirname(__FILE__), %W[.. .. lib virtualbox])

# Configuration settings/info
IntegrationInfo = {
  :test_unsafe => !!ENV["TEST_UNSAFE"],
  :vm_name => "test_vm"
}

# Mapping of VirtualBox::VM property keys to attributes in the
# `showvminfo` output.
VM_MAPPINGS = {
  :uuid => "UUID",
  :name => "name",
  :os_type_id => "ostype",
  :memory_size => "memory",
  :vram_size => "vram",
  :cpu_count => "cpus",
  :accelerate_3d_enabled => "accelerate3d",
  :accelerate_2d_video_enabled => "accelerate2dvideo",
  :clipboard_mode => "clipboard",
  :monitor_count => "monitorcount"
}

BIOS_MAPPINGS = {
  :acpi_enabled => "acpi",
  :io_apic_enabled => "ioapic"
}

HWVIRT_MAPPINGS = {
  :enabled => "hwvirtex",
  :exclusive => "hwvirtexexcl",
  :nested_paging => "nestedpaging",
  :vpid => "vtxvpid"
}

CPU_MAPPINGS = {
  :pae => "pae",
  :synthetic => "synthcpu"
}

STORAGE_MAPPINGS = {
  :port_count => "portcount",
  :controller_type => "type"
}

SHARED_FOLDER_MAPPINGS = {
  :host_path => "path"
}

NETWORK_ADAPTER_MAPPINGS = {
  :mac_address => "macaddress",
  :cable_connected => "cableconnected"
}

FORWARDED_PORT_MAPPINGS = {
  :protocol => "protocol",
  :hostport => "hostport",
  :guestport => "guestport"
}
