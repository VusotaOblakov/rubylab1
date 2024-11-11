require 'logger'

module MyApplicationName
  class LoggerManager
    class << self
      attr_reader :logger

      def init_logger(config)
        log_directory = config['logging']['directory']
        log_level = config['logging']['level']
        application_log = config['logging']['files']['application_log']
        error_log = config['logging']['files']['error_log']


        Dir.mkdir(log_directory) unless Dir.exist?(log_directory)


        @logger = Logger.new(File.join(log_directory, application_log))
        @logger.level = Logger.const_get(log_level.upcase)

        @error_logger = Logger.new(File.join(log_directory, error_log))
        @error_logger.level = Logger::ERROR
      end

      def log_processed_file(message)
        @logger.info(message)
      end

      def log_error(error_message)
        @error_logger.error(error_message)
      end
    end
  end
end
