# What's New in 0.2.x?

## Common Saving Convention

All models now implement a common saving convention. `save` will always return `true`
on success and `false` on failure. Additionally, an optional parameter `raise_error`
is available on save for all models which will cause failure to raise a 
{VirtualBox::Exceptions::CommandFailedException} which contains the reason for
failure.

This change allowed uniformity across all the models and also increased the error
checking ability of developers.

## AttachedDevice Creation

{VirtualBox::AttachedDevice} objects can now be created from scratch. A
quick example below:

    ad = VirtualBox::AttachedDevice.new
    ad.port = 0
    ad.image = VirtualBox::HardDrive.find("my-hd")
    storate_controller.devices << ad
    ad.save

## Empty Drives

{VirtualBox::DVD} now supports empty drives. That is, you can create a
DVD object which represents an empty drive by calling {VirtualBox::DVD.empty_drive}.
This object can be used as an image when creating a new or modifying an
existing {VirtualBox::AttachedDevice}.

## VM Saving Propagates Fully

Previously, when saving a {VirtualBox::VM}, it would only save the `nics`
relationship in addition to its own attributes. This was because only those
were editable, at the time. Now that {VirtualBox::AttachedDevice} can be
edited and created, virtual machine objects save **all** relationships when
`save` is called. This means you can do things like the following, and 
they'll work as expected:

    vm = VirtualBox::VM.find("Foo")
    vm.storage_controllers[0].devices[0].image = VirtualBox::DVD.empty_drive
    vm.save

## Bug Fixes & Testing Improvements

This release has 100% test coverage based on RCov's output and fixes
many bugs which existed in 0.1.x.