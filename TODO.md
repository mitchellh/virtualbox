# VirtualBox 4.1 TODOs:

* NetworkAdapter uses `network_adapter_counter` which is no longer supported.
  It needs to use `get_max_network_adapters` instead.
* NetworkAdapter `attach_to_*` methods are gone. Use `attachment_type` property
  instead.
* Appliance import must supply import options
