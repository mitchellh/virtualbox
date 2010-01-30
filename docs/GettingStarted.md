# Getting Started with the VirtualBox Gem

* [Basic Conventions](#basic-conventions)
    * [Finding Models](#bc-finding-models)
    * [Accessing Models](#bc-accessing-models)
    * [Modifying Models](#bc-modifying-models)
    * [Saving Models](#bc-saving-models)

<a name="basic-conventions"></a>
# Basic Conventions

The entire virtualbox library follows a few conventions to make sure
things work uniformly across the entire codebase, and so that nothing
should surprise any developers once they understand these conventions.

When browsing the documentation, you'll probably notice that a lot of the
classes inherit from {VirtualBox::AbstractModel}. This just means that all
these classes act the same way! Every {VirtualBox::AbstractModel AbstractModel}
shares the following behaviors:

* Finding
* Accessing
* Modifying
* Saving

These behaviors should be similar if not the exact same across all
virtualbox models. Each of these behaviors is covered below.

<a name="bc-finding-models"></a>
## Finding Models

All data models have a `find` or `all` method (or sometimes both!) These
methods do what you expect them to: `all` will return an array of all instances
of that model which is typically unordered. `find` will allow you to find a
specific instance of that model, typically by name or UUID. Below are a couple
examples of this.

### All

This example uses {VirtualBox::HardDrive}. As you can see, its just an
unmodified ruby `Array` which is returned by `all`. This can be used find,
sort, enumerate, etc.

    drives = VirtualBox::HardDrive.all
    puts "You have #{drives.length} hard drives!"

    drives.each do |drive|
      puts "Drive: #{drive.uuid}"
    end

In the case that `all` returns an empty array, this simply means that none
of that model exist.

### Find

This example uses {VirtualBox::VM}, which will probably be the most common
model you search for.

    vm = VirtualBox::VM.find("MyVM")
    puts "This VM has #{vm.memory} MB of RAM allocated to it."

Find can also be used with UUIDs:

    vm = VirtualBox::VM.find("3d0f87b4-50f7-4fc5-ad89-93375b1b32a3")
    puts "This VM's name is: #{vm.name}"

When a find fails, it will return `nil`.

<a name="bc-accessing-models"></a>
## Accessing Models

Every model has an _attribute list_ associated with it. These attributes are
what can be accessed on the model via the typical ruby attribute accessing
syntax with the `.` (dot) operator. Because these methods are generated
dynamically, they don't show up as methods in the documentation. Because of this,
attributes are listed for every model in their overviews. For examples, see the
overviews of {VirtualBox::VM}, {VirtualBox::HardDrive}, etc.

In addition to an attribute list, many models also have _relationships_.
Relationships are, for our purposes, similar enough to attributes that they
can be treated the same. Relationship accessing methods are also dynamically
generated, so they are listed within the overviews of the models as well (if they
have any). Relationships allow two models to show that they are connected in some
way, and can therefore be accessed through each other.

### Attributes

Reading attributes is simple. Let's use a {VirtualBox::VM} as an example:

    vm = VirtualBox::VM.find("FooVM")

    # Accessing attributes:
    vm.memory
    vm.name
    vm.boot1
    vm.ioapic

### Relationships

Relationships are read the exact same way as attributes. Again using a
{VirtualBox::VM} as an example:

    vm = VirtualBox::VM.find("FooVM")

    # storage_controllers is a relationship containing an array of all the
    # storage controllers on this VM
    vm.storage_controllers.each do |sc|
      puts "Storage Controller: #{sc.uuid}"
    end

The difference from an attribute is that while attributes are typically ruby
primitives such as `String` or `Boolean`, relationship objects are always other
virtualbox models such as {VirtualBox::StorageController}.

<a name="bc-modifying-models"></a>
## Modifying Models

In addition to simply reading attributes and relationships, most can be modified
as well. I say "most" because some attributes are `readonly` and some relationships
simply don't support being directly modified (though their objects may, I'll get to
this in a moment). By looking at the attribute list it is easy to spot a readonly
attribute, which will have the `:readonly` option set to `true`. Below is an example
of what you might see in the overview of some model:

    attribute :uuid, :readonly => true

In the above case, you could read the `uuid` attribute as normal, but it wouldn't support
modification (and you'll simply get a `NoMethodError` if you try to set it).

Relationships are a little bit trickier, since when discussing modifying a relationship,
it could either be taken to mean the items _in_ the relationship, or the relationship
itself. A good rule of thumb, assuming there exists a relationship `foos`,is if you ever
want to do `object.foos =` something, then you're _modifying the relationship_ and _not_
the objects. But if you ever do `object.foos[0].destroy`, then you're _modifying the
relationship objects_ and _not_ the relationship itself.

### Attributes

Attributes which support modification are modified like standard ruby attributes. The
following example uses {VirtualBox::HardDrive}:

    hd = VirtualBox::HardDrive.new
    hd.size = 2000 # megabytes
    hd.format = "VMDK"

As you can see, there is nothing sneaky going on here, and does what you expect.

### Relationships

Modifying relationships, on the other hand, is a little different. If the model supports
modifying the relationship (which it'll note in its respective documentation), then
you can set it just like an attribute. Below, we use {VirtualBox::AttachedDevice} as
an example:

    ad = VirtualBox::AttachedDevice.new

    # Attached devices have an image relationship
    ad.image = VirtualBox::DVD.empty_drive

If a relationship doesn't support setting it, it will raise a {VirtualBox::Exceptions::NonSettableRelationshipException}.

**Note**: Below is an example of modifying a relationship object, rather than a
relationship itself. The example below uses {VirtualBox::VM}.

    vm = VirtualBox::VM.find("FooVM")
    vm.storage_controllers[0].name = "Foo Controller"

<a name="bc-saving-models"></a>
## Saving Models

Saving models is _really_ easy: you simply call `save`. That's all! Well, there are
some subtleties, but that's the basic idea. `save` will typically **also save relationships**
so if you modify a relationship object or relationship itself, calling `save` on the
parent object will typically save the relationships as well. `save` always returns
`true` or `false` depending on whether the operation was a success or not. If you'd like
instead to know why a `save` failed, you can call the method with a `true` parameter
which sets `raise_errors` to `true` and will raise a {VirtualBox::Exceptions::CommandFailedException}
if there is a failure. The message on this object contains the reason.

Below is an example of saving a simple {VirtualBox::VM} object:

    vm = VirtualBox::VM.find("FooVM")

    # Double the memory
    vm.memory = vm.memory.to_i * 2

    # This will return true/false depending on success
    vm.save

Below is an example where an exception will be raised if an error occurs:

    vm = VirtualBox::VM.find("FooVM")
    vm.memory = "INVALID"

    # This will raise an exception, since the memory is invalid
    vm.save(true)