module MyApplicationName
  class Configurator
    attr_accessor :config

    # Ініціалізація конфігурації зі значеннями за промовчанням
    def initialize
      @config = {
        run_website_parser: 0,
        run_save_to_csv: 0,
        run_save_to_file: 0,
        run_save_to_json: 0,
        run_save_to_yaml: 0,
        run_save_to_sqlite: 0,
        run_save_to_mongodb: 0
      }
    end

    # Метод оновлення конфігураційних параметрів
    def configure(overrides = {})
      overrides.each do |key, value|
        if @config.key?(key)
          @config[key] = value
        else
          puts "Warning: Key '#{key}' is not a valid configuration option."
        end
      end
    end

    # Метод для отримання доступних конфігураційних ключів
    def self.available_methods
      %i[
        run_website_parser
        run_save_to_csv
        run_save_to_file
        run_save_to_json
        run_save_to_yaml
        run_save_to_sqlite
        run_save_to_mongodb
      ]
    end
  end
end
