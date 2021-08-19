module RailsPragmaticLogger
  module ActionController
    class LogSubscriber < ActiveSupport::LogSubscriber
      INTERNAL_PARAMS = %w[controller action format _method only_path].freeze

      # def start_processing(event)
      #   return unless config.log_start_processing

      #   logger.info(
      #     source: 'action_controller',
      #     message: 'Processing',
      #     action: event.payload[:action]
      #   )
      # end

      def process_action(event)
        if event.payload[:exception]
          logger.error(build_log(event).merge(extract_exception(event.payload)))
        else
          logger.info(build_log(event))
        end
      end

      private

      def logger
        ::ActionController::Base.logger
      end

      def build_log(event)
        {
          source: 'action_controller',
          controller: event.payload[:controller],
          action: event.payload[:action],
          method: event.payload[:method],
          path: strip_query_string(event.payload[:path]),
          params: get_params(event.payload[:params], event.duration&.round),
          format: event.payload[:format]&.downcase,
          status: event.payload[:status],
          ip: event.payload[:ip],
          allocations: (event.allocations if event.respond_to?(:allocations)),
          db: event.payload[:db_runtime]&.round,
          view: event.payload[:view_runtime]&.round,
          total: event.duration&.round,
        }.compact
      end

      def get_params(params, duration)
        return unless config.log_request_params
        return if config.log_request_params_threshold &&
          duration && config.log_request_params_threshold > duration

        (params.is_a?(Hash) ? params : params.to_unsafe_h).except(*INTERNAL_PARAMS)
      end

      def extract_exception(payload)
        return {} unless payload[:exception]

        exception_class, message = payload[:exception]

        {
          status: get_error_status_code(exception_class),
          exception: {
            class: exception_class,
            message: message,
            backtrace: get_backtrace(payload[:exception_object])
          }.compact
        }
      end

      def get_backtrace(exception_object)
        return unless exception_object

        backtrace_cleaner.clean(exception_object.backtrace)
      end

      def backtrace_cleaner
        @backtrace_cleaner ||= begin
          ActiveSupport::BacktraceCleaner.new.tap do |cleaner|
            cleaner.remove_silencers!
            cleaner.remove_filters!
            cleaner.add_filter { |line| line.gsub(Rails.root.to_s, '') }
            Gem.path.each do |path|
              cleaner.add_filter { |line| line.gsub(path, '') }
            end
          end
        end
      end

      def get_error_status_code(exception)
        status = ActionDispatch::ExceptionWrapper.rescue_responses[exception]
        Rack::Utils.status_code(status)
      end

      def strip_query_string(path)
        index = path.index('?')
        index ? path[0, index] : path
      end

      def config
        RailsPragmaticLogger::Railtie.config.pragmatic_logger
      end
    end
  end
end
