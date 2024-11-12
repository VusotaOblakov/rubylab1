require 'mechanize'
require 'yaml'
require 'fileutils'
require_relative 'logger_manager'
require_relative 'item'
require_relative 'item_collection'

module MyApplicationName
  class SimpleWebsiteParser
    attr_reader :config, :agent, :item_collection

    def initialize(config_file)
      # @config = YAML.load_file(config_file)
      @config = config_file

      @agent = Mechanize.new
      @item_collection = ItemCollection.new
    end

    # Начало парсинга сайту
    def start_parse
      LoggerManager.log_processed_file("Starting parse process")

      if check_url_response(config['web_scraping']['start_page'])
        page = agent.get(config['web_scraping']['start_page'])
        product_links = extract_products_links(page)

        # # Обробка сторінок продуктів у багатопоточному режимі
        threads = product_links.map do |link|
          Thread.new { parse_product_page(link) }
        end
        # threads = [Thread.new { parse_product_page(product_links.first) }]
        threads.each(&:join)

        LoggerManager.log_processed_file("Parsing completed")
      else
        LoggerManager.log_error("Start page is not available")
      end
    end

    # Витягує посилання на сторінки продуктів
    def extract_products_links(page)
      page.search(config['web_scraping']['product_link_selector']).map do |link|
        URI.join(config['web_scraping']['start_page'], link['href']).to_s
      end
    end

    # Парсинг сторінки продукту
    def parse_product_page(product_link)
      return unless check_url_response(product_link)
      LoggerManager.log_processed_file("product_link #{product_link} ")
      page = agent.get(product_link)
      name = extract_product_name(page)
      price = extract_product_price(page)
      description = extract_product_description(page)
      image_url = extract_product_image(page)
      if name.nil? || name.empty? || image_url.nil? || image_url.empty?
        LoggerManager.log_error("#{name} #{image_url}Incomplete data found for product at #{product_link}. Skipping...")
        return
      end
      LoggerManager.log_processed_file("found #{image_url} ")
      LoggerManager.log_processed_file("found #{name} ")
      LoggerManager.log_processed_file("found #{price} ")

      # category = config['web_scraping']['default_category'] || 'uncategorized'
      category = extract_category(page)

      sanitized_name = sanitize_filename(name)
      save_image(image_url, category, sanitized_name) if image_url

      item = Item.new(
        name: sanitized_name,
        price: price,
        description: description,
        category: category,
        image_path: "../media/#{category}/#{sanitized_name}.jpg"
      )
      item_collection.add_item(item)
      LoggerManager.log_processed_file("Parsed item: #{sanitized_name}")
    end

    # Методи отримання даних
    def extract_product_name(page)
      page.at(config['web_scraping']['product_name_selector'])&.text&.strip
    end

    def extract_category(page)
    category_element = page.at(config['web_scraping']['product_category_selector'])&.text&.strip
    category_element || config['web_scraping']['default_category']
    end
    
    def extract_product_price(page)
      page.at(config['web_scraping']['product_price_selector'])&.text&.strip
    end

    def extract_product_description(page)
      "Unknown description" 
    end

    def extract_product_image(page)
      URI.join(config['web_scraping']['start_page'], page.at(config['web_scraping']['product_image_selector'])&.[]('src')).to_s
    end

    # Перевірка доступності URL
    def check_url_response(url)
      agent.head(url).code == '200'
    rescue
      LoggerManager.log_error("Failed to access URL: #{url}")
      false
    end
    def sanitize_filename(name)
      name.gsub(/[^0-9A-Za-z.\-]/, '_')
    end
    def save_image(url, category, name)
      media_dir = File.join('..', 'media', category)
      FileUtils.mkdir_p(media_dir)
    
      
      # LoggerManager.log_processed_file("Sanitized name: #{sanitized_name}")
    
      # Шлях для збереження зображення
      file_path = File.join(media_dir, "#{name}.jpg")
      LoggerManager.log_processed_file("Saving image at: #{file_path}")
    
      
      agent.get(url).save(file_path)
      LoggerManager.log_processed_file("Image saved: #{file_path}")
    rescue => e
      LoggerManager.log_error("Failed to save image for #{name}: #{e.message}")
    end
  end
end
