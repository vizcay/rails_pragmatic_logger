require_relative "json_formatter"
require_relative "patch_tagged_logging"
require_relative "action_controller/log_subscriber"
require_relative "active_record/log_subscriber"
require_relative "action_view/log_subscriber"

module RailsPragmaticLogger
  class Railtie < ::Rails::Railtie
    config.pragmatic_logger = ActiveSupport::OrderedOptions.new
    config.pragmatic_logger.log_request_params   = false
    config.pragmatic_logger.log_start_processing = false
    config.pragmatic_logger.log_active_record    = false
    config.pragmatic_logger.log_action_view      = false
    config.pragmatic_logger.pretty_print_json    = false

    # Replace Rails logger initializer
    Rails::Application::Bootstrap.initializers.delete_if { |i| i.name == :initialize_logger }

    initializer :initialize_logger, after: :set_eager_load, group: :all do
      config = Rails.application.config

      # TODO: investigate further
      config.middleware.delete(Rails::Rack::Logger)

      log_file = config.respond_to?(:default_log_file) ?
        config.default_log_file : rails4_default_log_file(config)
      logger = ActiveSupport::Logger.new(log_file)
      logger.formatter = RailsPragmaticLogger::JsonFormatter.new
      Rails.logger = logger
    end

    # After any initializers run, but after the gems have been loaded
    config.after_initialize do
      RailsPragmaticLogger.swap_subscriber(
        ::ActionController::LogSubscriber,
        RailsPragmaticLogger::ActionController::LogSubscriber,
        :action_controller
      )

      RailsPragmaticLogger.swap_subscriber(
        ::ActiveRecord::LogSubscriber,
        RailsPragmaticLogger::ActiveRecord::LogSubscriber,
        :active_record
      )

      RailsPragmaticLogger.swap_subscriber(
        ::ActionView::LogSubscriber,
        RailsPragmaticLogger::ActionView::LogSubscriber,
        :action_view
      )
    end

    def rails4_default_log_file(config)
      path = config.paths["log"].first
      unless File.exist? File.dirname path
        FileUtils.mkdir_p File.dirname path
      end

      File.open(path, "a").tap do |f|
        f.binmode
        f.sync = true
      end
    end
  end
end
