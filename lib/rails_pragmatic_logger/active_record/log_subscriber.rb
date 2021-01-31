require_relative 'bind_values'

module RailsPragmaticLogger
  module ActiveRecord
    class LogSubscriber < ActiveSupport::LogSubscriber
      include BindValues

      IGNORE_PAYLOAD_NAMES = %w[SCHEMA EXPLAIN].freeze
      IGNORE_TRANSACTIONS = %w[BEGIN COMMIT ROLLBACK].freeze

      def sql(event)
        return unless RailsPragmaticLogger::Railtie.config.pragmatic_logger.log_active_record
        return if IGNORE_PAYLOAD_NAMES.include?(event.payload[:name])
        return if IGNORE_TRANSACTIONS.include?(event.payload[:sql])

        binds = bind_values(event.payload) unless (event.payload[:binds] || []).empty?

        logger.info({
          source: 'active_record',
          message: event.payload[:name],
          sql: event.payload[:sql],
          binds: binds
        }.compact)
      end

      private

      def logger
        ::ActiveRecord::Base.logger
      end
    end
  end
end
