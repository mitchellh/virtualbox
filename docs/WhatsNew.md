# What's New in 0.3.x?

## Shared Folders

Shared folders are a great feature of VirtualBox which allows the host system
to share data with guest systems easily using the native filesystem. Attaching,
modifying, and removing these shared folders are now supported. A quick example
below:

    vm = VirtualBox::VM.find("FooVM")
    folder = VirtualBox::SharedFolder.new
    folder.name = "hosthome"
    folder.hostpath = "/home/username"
    vm.shared_folders << folder
    vm.save

For full documentation on this new feature, read about them at
{VirtualBox::SharedFolder}.

## Validations

Many of the models for the virtualbox library now come complete with data
validations. These validations are performed within the library itself prior to
calling the virtualbox commands. They work very much the same was as ActiveRecord
validations:

    sf = VirtualBox::SharedFolder.new(hash_of_values)
    if !sf.valid?
      puts "#{sf.errors.length} errors with the folder"
    else
      sf.save
    end

In addition to `valid?` there is `errors` which returns a hash of all the errors,
including errors on relationships. There is also the `validate` method which
runs the validations, but you really shouldn't have the need to call that directly.

All validations are run automatically on `save`, which will return `false` if
they fail. If you choose to raise errors on the save, a `ValidationFailedException`
will be raised (in contrast to a `CommandFailedException`, which serves its own
role).