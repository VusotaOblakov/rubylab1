require 'faker'
require_relative 'logger_manager'

module MyApplicationName
  class Item
    include Comparable

    attr_accessor :name, :price, :description, :category, :image_path

    
    def initialize(attributes = {})
      @name = attributes[:name] || "Unknown Item"
      @price = attributes[:price] || 0
      @description = attributes[:description] || "Unknown description"
      @category = attributes[:category] || "Unknown category"
      @image_path = attributes[:image_path] || "path/to/default_image.jpg"

      # Логування ініціалізації об'єкта
      LoggerManager.log_processed_file("Created object Item: #{@name}")

      # Застосування блоку, якщо передано
      yield(self) if block_given?
    end

   
    def to_s
      "Item: #{name}, Price: #{price}, Description: #{description}, Category: #{category}, Image Path: #{image_path}"
    end

 
    def to_h
      { name: name, price: price, description: description, category: category, image_path: image_path }
    end

 
    def inspect
      "<Item name: #{name}, price: #{price}, category: #{category}>"
    end

  
    def update
      yield(self) if block_given?
    end


    def <=>(other)
      price <=> other.price
    end


    alias_method :info, :to_s
    alias_method :hash, :to_h


    def self.generate_fake
      new(
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price,
        description: Faker::Lorem.sentence,
        category: Faker::Commerce.department,
        image_path: "path/to/fake_image.jpg"
      )
    end
  end
end
