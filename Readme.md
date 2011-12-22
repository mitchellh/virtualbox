**This gem is no longer under active development. Please do not use it.**

I've decided to stop developing this library since the main user of the library
and the purpose it was created (Vagrant) no longer makes use of it. The reasoning
behind this is because the `win32ole` support on Windows is simply painful and
doesn't support all the features necessary to fully support the VirtualBox
API.

If you're interested in maintaining this gem, please contact me (mitchellh).

# VirtualBox Ruby Gem

The VirtualBox ruby gem is a library which allows anyone to control VirtualBox
from ruby code! Create, destroy, start, stop, suspend, and resume virtual machines.
Also list virtual machines, list hard drives, network devices, etc.

## Installation and Requirements

First you need to install [VirtualBox](http://www.virtualbox.org/) which is available for
Windows, Linux, and OS X. After installation, install the gem:

    sudo gem install virtualbox

The gem uses the native COM interface with VirtualBox provides to communicate with
VirtualBox. On Windows, this is globally available. On Linux-based machines, the gem
uses Ruby-FFI to talk to a dynamic library. No configuration should be necessary.

## Basic Usage

The virtualbox gem is modeled after ActiveRecord. If you've used ActiveRecord, you'll
feel very comfortable using the virtualbox gem.

There is a [quick getting started guide](http://mitchellh.github.com/virtualbox/file.GettingStarted.html) to
get you acquainted with the conventions of the virtualbox gem.

Complete documentation can be found at [http://mitchellh.github.com/virtualbox](http://mitchellh.github.com/virtualbox).

Below are some examples:

    require 'virtualbox'

    vm = VirtualBox::VM.find("my-vm")

    # Let's first print out some basic info about the VM
    puts "Memory: #{vm.memory_size}"

    # Let's modify the memory and name...
    vm.memory_size = 360
    vm.name = "my-renamed-vm"

    # Save it!
    vm.save

## Known Issues or Uncompleted Features

VirtualBox has a _ton_ of features! As such, this gem is still not totally complete.
You can see the features that are still left to do in the TODO file.

## Reporting Bugs or Feature Requests

Please use the [issue tracker](https://github.com/mitchellh/virtualbox/issues).

## Contributing

If you'd like to contribute to VirtualBox, the first step to developing is to
clone this repo, get [bundler](http://github.com/carlhuda/bundler) if you
don't have it already, and do the following:

    bundle install --relock
    rake

This will run the test suite, which should come back all green! Then you're good to go!

## Special Thanks

These folks went above and beyond with contributions to the virtualbox gem, and
for that, I have to say "thanks!"

* [Kieran Pilkington](http://github.com/KieranP)
* [Aleksey Palazhchenko](http://github.com/AlekSi)
