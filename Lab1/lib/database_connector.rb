require 'sqlite3'
require 'mongo'
require 'yaml'

module MyApplicationName
  class DatabaseConnector
    attr_reader :db

    def initialize(config_file)
      # @config = YAML.load_file(config_file)['database_config']
      @config = config_file

      @db = nil
    end

    # Підключення до бази даних залежно від типу
    def connect_to_database
      case @config['database_type']
      when 'sqlite'
        connect_to_sqlite
      when 'mongodb'
        connect_to_mongodb
      else
        raise "Unsupported database type: #{@config['database_type']}"
      end
    rescue => e
      puts "Failed to connect to database: #{e.message}"
    end

    # Закриття з'єднання з базою даних
    def close_connection
      if @db
        if @config['database_type'] == 'mongodb'
          @db.close
        else
          @db.close if @db.respond_to?(:close)
        end
        @db = nil
        puts "Connection to #{@config['database_type']} closed."
      end
    end

    private

    # Підключення до бази даних SQLite
    def connect_to_sqlite
      db_file = @config['sqlite_database']['db_file']
      
      # Створюємо директорію, якщо вона не існує
      db_dir = File.dirname(db_file)
      FileUtils.mkdir_p(db_dir) unless Dir.exist?(db_dir)
    
      @db = SQLite3::Database.new(db_file)
      @db.busy_timeout(@config['sqlite_database']['timeout'])
      puts "Connected to SQLite database at #{db_file}."
    rescue SQLite3::Exception => e
      puts "SQLite connection error: #{e.message}"
    end

    # Підключення до бази даних MongoDB
    def connect_to_mongodb
      client = Mongo::Client.new(@config['mongodb_database']['uri'])
      @db = client.use(@config['mongodb_database']['db_name'])
      puts "Connected to MongoDB database #{@config['mongodb_database']['db_name']}."
    rescue Mongo::Error => e
      puts "MongoDB connection error: #{e.message}"
    end
  end
end
