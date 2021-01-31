module RailsPragmaticLogger
  module ActionView
    class LogSubscriber < ActiveSupport::LogSubscriber
      # def render_template(event)
      #   return unless config.pragmatic_logger.log_action_view

      #   logger.info(
      #     source: 'action_view',
      #     template: from_rails_root(event.payload[:identifier]),
      #     total: event.duration.round
      #   )
      # end

      # def render_partial(event)
      #   return unless config.pragmatic_logger.log_action_view

      #   logger.info(
      #     source: 'action_view',
      #     partial: event.payload[:identifier]
      #   )
      # end

      # def render_collection(event)
      #   return unless config.pragmatic_logger.log_action_view
      # end

      # def start(name, id, payload)
      #   if config.pragmatic_logger.log_action_view
      #     logger.info({
      #       source: 'action_view',
      #       message: 'Started',
      #       template: from_rails_root(payload[:identifier]),
      #       layout: payload[:layout]
      #     }.compact)
      #   end

      #   super
      # end

      private

      def logger
        ::ActionController::Base.logger
      end

      def from_rails_root(path)
        path.sub(rails_root, '').sub(%r{^app/views/}, '')
      end

      def rails_root
        @rails_root ||= "#{Rails.root}/"
      end

      def config
        RailsPragmaticLogger::Railtie.config
      end
    end
  end
end
