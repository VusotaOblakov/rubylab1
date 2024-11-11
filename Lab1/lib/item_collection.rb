require 'json'
require 'csv'
require 'yaml'
require_relative 'item_container'
require_relative 'logger_manager'

module MyApplicationName
  class ItemCollection
    include ItemContainer
    include Enumerable

    attr_accessor :items

    def initialize
      @items = []
    end

    def each(&block)
      @items.each(&block)
    end

    # Методи збереження даних
    def save_to_file(filename)
      File.open(filename, 'w') { |file| @items.each { |item| file.puts item.to_s } }
      MyApplicationName::LoggerManager.log_processed_file("Saved items to file #{filename}")
    end

    def save_to_json(filename)
      File.write(filename, @items.map(&:to_h).to_json)
      MyApplicationName::LoggerManager.log_processed_file("Saved items to JSON #{filename}")
    end

    def save_to_csv(filename)
      CSV.open(filename, 'w') do |csv|
        csv << @items.first.to_h.keys
        @items.each { |item| csv << item.to_h.values }
      end
      MyApplicationName::LoggerManager.log_processed_file("Saved items to CSV #{filename}")
    end

    def save_to_yml(directory)
      @items.each_with_index do |item, index|
        File.write(File.join(directory, "item_#{index + 1}.yml"), item.to_h.to_yaml)
      end
      MyApplicationName::LoggerManager.log_processed_file("Saved items to YAML files in #{directory}")
    end

    # Генерація тестових даних
    def generate_test_items(count)
      count.times { add_item(MyApplicationName::Item.generate_fake) }
    end
    # Метод для сохранения данных в базу данных
    def save_to_database(db_connector, db_type)
      case db_type
      when 'sqlite'
        save_to_sqlite(db_connector)
      when 'mongodb'
        save_to_mongodb(db_connector)
      else
        puts "Unsupported database type: #{db_type}"
      end
    end

    private


    def save_to_sqlite(db_connector)
      db = db_connector.db
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price TEXT,
          description TEXT,
          category TEXT,
          image_path TEXT
        )
      SQL
    
      items.each do |item|
        db.execute("INSERT INTO items (name, price, description, category, image_path) VALUES (?, ?, ?, ?, ?)", 
                   [item.name, item.price, item.description, item.category, item.image_path])
      end
      puts "Data saved to SQLite database"
    rescue SQLite3::Exception => e
      puts "SQLite error: #{e.message}"
    end


    def save_to_mongodb(db_connector)
      collection = db_connector.db[:items]
      items.each do |item|
        document = {
          name: item.name,
          price: item.price,
          description: item.description,
          category: item.category,
          image_path: item.image_path
        }
        collection.insert_one(document)
      end
      puts "Data saved to MongoDB"
    rescue Mongo::Error => e
      puts "MongoDB error: #{e.message}"
    end
  end
end
