#------------------------------------------------------------
# Hooks
#------------------------------------------------------------
# Unsafe tags specify that a test modifies (writes or deletes)
# actual data in VirtualBox.
Around('@unsafe') do |scenario, block|
  block.call if IntegrationInfo[:test_unsafe]
end

#------------------------------------------------------------
# Warning/Info messages about settings.
#------------------------------------------------------------
if !IntegrationInfo[:test_unsafe]
  puts <<-MSG
========================================================================

For your own safety, unsafe tests (tests which modify actual VirtualBox
data), are disabled unless the environmental variable TEST_UNSAFE is
set. To enable unsafe tests, the easiest way is to do the following:

    TEST_UNSAFE=yes rake test:integration

========================================================================
MSG
end

