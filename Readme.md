# VirtualBox Ruby Gem

The VirtualBox ruby gem is a library which allows anyone to control VirtualBox 
from ruby code! Create, destroy, start, stop, suspend, and resume virtual machines.
Also list virtual machines, list hard drives, network devices, etc.

## Installing

    sudo gem install virtualbox

## Basic Usage

I tried to model the VirtualBox gem in a way that would be familiar to ActiveRecord
users. Examples are best:

    require 'virtualbox'
    
    vm = VirtualBox::VM.find("my-vm")
    vm.memory = 256 if vm.memory > 256
    vm.save

Detailed documentation can be found here (TODO).

## Supported Features

VirtualBox has a ton of features! As such, this gem is incomplete. The following list
is an up-to-date feature list:

* Finding existing Virtual Machines (VirtualBox::VM.find)
* Editing of most simple VM attributes. But no serial ports, storage controllers, etc.
* Editing of most simple nic attributes for an existing VM.
* Listing of all hard drives (VirtualBox::HardDrive.all)
* Importing VMs from OVF

What is not supported, but will be soon:

* Hard drive cloning

## Contributing

If you'd like to contribute to VirtualBox, the first step to developing is to
clone this repo, get [wycat's bundler](http://github.com/wycats/bundler) if you
don't have it already, and do the following:

    gem bundle test
    rake

This will run the test suite, which should come back all green! Then you're good to go!
