module RailsPragmaticLogger
  class JsonFormatter
    def call(severity, timestamp, _progname, message)
      output = to_hash(severity, timestamp, message)
      if config&.pretty_print_json
        JSON.pretty_generate(output) + "\n"
      else
        output.to_json + "\n"
      end
    end

    protected

    def to_hash(severity, timestamp, message)
      { type: severity, time: timestamp.iso8601 }.tap do |output|
        if message.is_a?(Hash)
          output.merge!(message)
        else
          output[:message] = message
        end
      end
    end

    private

    def config
      RailsPragmaticLogger::Railtie.config.pragmatic_logger
    end
  end
end
