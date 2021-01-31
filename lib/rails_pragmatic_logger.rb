require_relative "rails_pragmatic_logger/version"
require_relative "rails_pragmatic_logger/railtie"

module RailsPragmaticLogger
  def self.swap_subscriber(old_class, new_class, notifier)
    subscribers = ActiveSupport::LogSubscriber.subscribers.select { |s| s.is_a?(old_class) }
    subscribers.each { |subscriber| unattach(subscriber) }

    new_class.attach_to(notifier)
  end

  def self.unattach(subscriber)
    subscriber_patterns(subscriber).each do |pattern|
      ActiveSupport::Notifications.notifier.listeners_for(pattern).each do |sub|
        next unless sub.instance_variable_get(:@delegate) == subscriber

        ActiveSupport::Notifications.unsubscribe(sub)
      end
    end

    ActiveSupport::LogSubscriber.subscribers.delete(subscriber)
  end

  def self.subscriber_patterns(subscriber)
    subscriber.patterns.respond_to?(:keys) ?
      subscriber.patterns.keys :
      subscriber.patterns
  end
end
