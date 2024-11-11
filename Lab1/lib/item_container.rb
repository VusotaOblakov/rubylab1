
module MyApplicationName
  module ItemContainer
    module ClassMethods
      def class_info
        "Class: #{name}, Version: 1.0"
      end

      def item_count
        @item_count ||= 0
      end

      def increment_item_count
        @item_count = item_count + 1
      end
    end

    module InstanceMethods
      def add_item(item)
        @items << item
        MyApplicationName::LoggerManager.log_processed_file("Added item: #{item.name}")
      end

      def remove_item(item)
        @items.delete(item)
        MyApplicationName::LoggerManager.log_processed_file("Removed item: #{item.name}")
      end

      def delete_items
        @items.clear
        MyApplicationName::LoggerManager.log_processed_file("Deleted all items")
      end

      def method_missing(method, *args)
        if method == :show_all_items
          @items.each { |item| puts item.to_s }
        else
          super
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end
  end
end
