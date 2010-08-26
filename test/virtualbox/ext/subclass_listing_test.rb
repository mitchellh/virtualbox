require File.expand_path("../../../test_helper", __FILE__)
require 'virtualbox/ext/subclass_listing'

class SubclassListingTest < Test::Unit::TestCase
  class A
    include VirtualBox::SubclassListing
  end
  class B < A; end
  class C < B; end
  class D < A; end
  class E
    include VirtualBox::SubclassListing
  end
  class F < E; end

  should "list subclasses, including sub-subclasses, etc" do
    assert_equal [F], E.subclasses
    assert_equal [C], B.subclasses
    assert_equal [B, C, D], A.subclasses.sort_by { |c| c.name }
  end

  should "list direct subclasses if flag is set" do
    assert_equal [B, D], A.subclasses(true).sort_by { |c| c.name }
  end
end
