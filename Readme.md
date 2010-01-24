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

## Contributing

If you'd like to contribute to VirtualBox, the first step to developing is to
clone this repo, get [wycat's bundler](http://github.com/wycats/bundler) if you
don't have it already, and do the following:

    gem bundle test
    rake

This will run the test suite, which should come back all green! Then you're good to go!
