module ActiveSupport
  module TaggedLogging
    module Formatter
      def call(severity, timestamp, progname, msg)
        if msg.is_a?(Hash)
          super(severity, timestamp, progname, merge_with_tags(msg))
        else
          super(severity, timestamp, progname, "#{tags_text}#{msg}")
        end
      end

      private

      def merge_with_tags(msg)
        tags = current_tags
        if tags.any?
          msg.merge({ tags: tags }.compact)
        else
          msg
        end
      end
    end
  end
end
