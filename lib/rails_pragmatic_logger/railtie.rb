require_relative "json_formatter"
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

      logger = ActiveSupport::Logger.new(config.default_log_file)
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
  end
end
