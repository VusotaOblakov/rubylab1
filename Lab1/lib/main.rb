# Підключаємо необхідні бібліотеки та класи
require_relative 'app_config_loader'
require_relative 'logger_manager'
require_relative 'item'
require_relative 'item_collection'
require_relative 'configurator'
require_relative 'simple_website_parser'
require_relative 'database_connector'
require_relative 'engine'
# Ініціалізуємо шлях до основного конфігураційного файлу та директорії з YAML файлами
config_file = '../config/default_config.yaml'
config_dir = '../config/'
AppConfigLoader.load_libs('lib')
# Створюємо екземпляр AppConfigLoader та завантажуємо конфігурацію
config_loader = AppConfigLoader.new(config_file, config_dir)
config_data = config_loader.config

# Виводимо завантажені дані у форматі JSON для зручного перегляду
config_loader.pretty_print_config_data
# Ініціалізація логера з параметрами конфігурації
MyApplicationName::LoggerManager.init_logger(config_data)
configurator = MyApplicationName::Configurator.new


puts "Started config:"
puts configurator.config

# Оновлюємо параметри конфігурації
configurator.configure(
  run_website_parser: 1,
  run_save_to_csv: 1,
  run_save_to_file: 1,
  run_save_to_json: 1,
  run_save_to_yaml: 1,
  run_save_to_sqlite: 1,
  run_save_to_mongodb: 0,
)
puts "\nДоступні конфігураційні ключі:"
puts MyApplicationName::Configurator.available_methods
# Передаємо Configurator в Engine і запускаємо
engine = MyApplicationName::Engine.new(configurator)
engine.run(config_data)
MyApplicationName::LoggerManager.log_processed_file("Тестове повідомлення: перевірка логування")
MyApplicationName::LoggerManager.log_error("Тестове повідомлення: перевірка логування помилок")

# fake_item = MyApplicationName::Item.generate_fake

# if fake_item
#   puts fake_item.info
#   puts "Hash Code: #{fake_item.hash}"
# end
# # Створюємо колекцію та додаємо тестові дані
# collection = MyApplicationName::ItemCollection.new
# collection.generate_test_items(5)

# # Перевірка додавання товару
# puts "\nДодаємо новий товар..."
# new_item = MyApplicationName::Item.generate_fake
# collection.add_item(new_item)
# puts "Доданий товар: #{new_item.to_s}"

# # Перевірка видалення товару
# puts "\nВидаляємо товар..."
# collection.remove_item(new_item)
# puts "Вилучений товар: #{new_item.to_s}"

# # Перевірка видалення всіх товарів
# puts "\nВидаляємо всі товари..."
# collection.delete_items
# puts "Усі товари видалені. Кількість товарів: #{collection.items.size}"

# # Повторне додавання тестових товарів для збереження
# collection.generate_test_items(5)

# # Перевірка методу show_all_items
# puts "\nВсі товари в колекції:"
# collection.show_all_items

# # Збереження даних у різних форматах
# puts "\nЗберігаємо колекцію у різні формати..."
# collection.save_to_file('../output/items.txt')
# collection.save_to_json('../output/items.json')
# collection.save_to_csv('../output/items.csv')

# # Створюємо директорію для збереження в YAML, якщо її немає
# Dir.mkdir('../output/yaml_directory') unless Dir.exist?('../output/yaml_directory')
# collection.save_to_yml('../output/yaml_directory')
# puts "Збереження завершено."

# unique_categories = collection.map(&:category).uniq
# puts "Унікальні категорії: #{unique_categories.join(', ')}"

# sorted_items = collection.sort_by(&:price)
# puts "\nТовари відсортовані за ціною:"
# sorted_items.each { |item| puts "#{item.name}: #{item.price}" }

