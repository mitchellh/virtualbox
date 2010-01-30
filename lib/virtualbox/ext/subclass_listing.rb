# From: http://snippets.dzone.com/posts/show/2992
module VirtualBox::SubclassListing
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def subclasses(direct = false)
      classes = []
      if direct
        ObjectSpace.each_object(Class) do |c|
          next unless c.superclass == self
          classes << c
        end
      else
        ObjectSpace.each_object(Class) do |c|
          next unless c.ancestors.include?(self) and (c != self)
          classes << c
        end
      end
      classes
    end
  end
end