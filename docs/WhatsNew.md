# What's New in 0.4.x?

## "Extra Data" on VMs / Global

Extra data is persistent key-value storage which is available as a way to store any information
wanted. VirtualBox uses it for storing statistics and settings. You can use it for anything!
Setting extra data on virtual machines is now as easy as a ruby hash:

    vm = VirtualBox::VM.find("FooVM")
    vm.extra_data["i_was_here"] = "yes!"
    vm.save

Read more about extra data {VirtualBox::ExtraData here}.

## Port Forwarding

If a VM is using NAT for its network, the host machine can't access any outward facing
services of the guest (for example: a web host, ftp server, etc.). Port forwarding is
one way to facilitate this need. Port forwarding is straight forward to setup:

    vm = VirtualBox::VM.find("FooVM")
    port = VirtualBox::ForwardedPort.new
    port.name = "http"
    port.guestport = 80
    port.hostport = 8080
    vm.forwarded_ports << port
    vm.save

Read more about port forwarding {VirtualBox::ForwardedPort here}.

## More Ruby Versions Supported!

Previously, virtualbox only supported 1.8.7. It now supports 1.8.6 and 1.9.x thanks
to AleksiP.