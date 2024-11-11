require 'yaml'
require 'zip'
require_relative 'simple_website_parser'
require_relative 'database_connector'
require_relative 'logger_manager'
# require_relative 'archive_sender'
require_relative 'item_collection'

module MyApplicationName
  class Engine
    attr_reader :item_collection, :configurator

    def initialize(configurator)
      @configurator = configurator
      @item_collection = ItemCollection.new
      @db_connector = nil
    end

    # Метод запуску програми
    def run(config_data)
      initialize_logging(config_data)
      connect_to_database(config_data)
      run_methods(config_data)
      close_database_connection()
    end

    # Виконання методів на основі конфігурації
    def run_methods(config_data)
      configurator.config.each do |method, enabled|
        if enabled == 1
          if respond_to?(method, true)
            send(method,config_data)
            LoggerManager.log_processed_file("Executed method: #{method}")
          else
            LoggerManager.log_error("Method #{method} is not available")
          end
        end
      end
    end

    def initialize_logging(config_data)
      LoggerManager.init_logger(config_data)
    end
    
    def run_website_parser(config_data)
      parser = SimpleWebsiteParser.new(config_data)
      parser.start_parse
      @item_collection = parser.item_collection
    end

    def run_save_to_csv(config_data)
      item_collection.save_to_csv('../output/items.csv')
    end

    def run_save_to_json(config_data)
      item_collection.save_to_json('../output/items.json')
    end

    def run_save_to_file(config_data)
      item_collection.save_to_json('../output/items.txt')
    end

    def run_save_to_yaml(config_data)
      Dir.mkdir('../output/yaml_directory') unless Dir.exist?('../output/yaml_directory')
      item_collection.save_to_yml('../output/yaml_directory')
    end

    def run_save_to_sqlite(config_data)
      item_collection.save_to_database(@db_connector, "sqlite")
    end

    def run_save_to_mongodb(config_data)
      item_collection.save_to_database(@db_connector, 'mongodb')
    end

    private

    # Підключення до бази даних
    def connect_to_database(config_data)
      @db_connector = DatabaseConnector.new(config_data['database_config'])
      @db_connector.connect_to_database
    end

    # Закриття з'єднання з базою даних
    def close_database_connection
      @db_connector.close_connection if @db_connector
    end
  end
end
