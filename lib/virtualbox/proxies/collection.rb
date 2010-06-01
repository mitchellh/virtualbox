module VirtualBox
  module Proxies
    # A relationship which can be described as a collection, which
    # is a set of items.
    class Collection < Array
      attr_reader :parent

      def initialize(parent, item_klass=nil, *args)
        super()

        @parent = parent
        @item_klass = item_klass
        @other = args
      end

      # Creates a new item for this collection and returns the
      # instance. The item is automatically put into this
      # collection. `create` happens immediately, meaning that even
      # without a `save`, the item will already exist.
      def create(*args)
        item =  nil

        if @item_klass.respond_to?(:create)
          args = @other + args
          item = @item_klass.create(self, *args)
          self << item
        end

        item
      end

      def <<(item)
        item.added_to_relationship(self) if item.respond_to?(:added_to_relationship)
        push(item)
      end

      def clear
        each do |item|
          delete(item)
        end
      end

      def delete(item, no_callback=false)
        return unless super(item)
        item.removed_from_relationship(self) if !no_callback && item.respond_to?(:removed_from_relationship)
      end
    end
  end
end
