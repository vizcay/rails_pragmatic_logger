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
        logger.info({
          source: 'action_controller',
          controller: event.payload[:controller],
          action: event.payload[:action],
          method: event.payload[:method],
          path: event.payload[:path],
          params: get_params(event.payload[:params]),
          format: event.payload[:format]&.downcase,
          status: event.payload[:status],
          ip: event.payload[:ip],
          allocations: (event.allocations if event.respond_to?(:allocations)),
          db: event.payload[:db_runtime]&.round,
          view: event.payload[:view_runtime]&.round,
          total: event.duration&.round,
        }.compact)
      end

      private

      def logger
        ::ActionController::Base.logger
      end

      def get_params(params)
        return unless config.log_request_params

        (params.is_a?(Hash) ? params : params.to_unsafe_h).except(*INTERNAL_PARAMS)
      end

      def config
        RailsPragmaticLogger::Railtie.config.pragmatic_logger
      end
    end
  end
end
