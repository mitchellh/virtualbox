# What's New in 0.5.x?

## HUGE Speed Boost! Very few system calls!

Most of the data retrieved by the virtualbox library now comes via XML parsing, rather
than making calls to `VBoxManage`. This results in a drastic speedup. The few relationships or
attributes which require a system call are typically _lazy loaded_ (covered below), so they
don't incur a performance penalty unless they're used.

The one caveat is that you now need to set the path to the global VirtualBox configuration
XML. The virtualbox library will do its best to guess this path based on the operating
system, but this is hardly foolproof. To set the virtualbox config path, it is a simple
one-liner:

    # Remember, this won't be necessary MOST of the time
    VirtualBox::Global.vboxconfig = "~/path/to/VirtualBox.xml"

## Lazy Loading of Attributes and Relationships

Although still not widely used (will be in future patch releases), some attributes and
relationships are now _lazy loaded_. This means that since they're probably expensive
to load (many system calls, heavy parsing, etc.) they aren't loaded initially. Instead,
they are only loaded if they're used. This means that you don't incur the penalty cost
of loading them unless you use it! Fantastic!

There is no real "example code" for this feature since to the casual user, it happens
transparently in the background and generally "just works." If you're _really_ curious,
then feel free to check out any class which derives from {VirtualBox::AbstractModel}
and any attribute or relationship with the `:lazy => true` option is lazy loaded!

## System Properties

A small but meaningful update is the ability to view the system properties for the
host system which VirtualBox is running. This is done via the {VirtualBox::SystemProperty}
class, which is simply a `Hash`. System properties are immutable properties defined
by the host system, which typically are limits imposed upon VirtualBox, such as
maximum RAM size or default path to machine files. Retrieving the system properties
is quite easy:

    properties = VirtualBox::SystemProperty.all
    properties.each do |key, value|
      puts "#{key} = #{value}"
    end