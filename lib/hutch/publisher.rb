require 'securerandom'
require 'hutch/logging'
require 'hutch/exceptions'

module Hutch
  class Publisher
    include Logging
    attr_reader :connection, :channel, :exchange, :config

    def initialize(connection, channel, config = Hutch::Config, broker)
      @connection = connection
      @channel    = channel
      @exchanges   = {}
      @config     = config
      @broker     = broker
    end

    def set_exchanges(exchanges)
      @exchanges = exchanges
    end

    def add_exchange(name, exchange)
      @exchanges[name] = exchange
    end

    def publish(routing_key, message, properties = {}, options = {})
      ensure_connection!(routing_key, message)

      p properties
      p "AAA"
      serializer = options[:serializer] || config[:serializer]
      p serializer

      non_overridable_properties = {
        routing_key:  routing_key,
        timestamp:    connection.current_timestamp,
        content_type: serializer.content_type,
      }
      properties[:message_id]   ||= generate_id
      p properties
      p "AAAŽŽŽŽ"

      payload = serializer.encode(message)

      log_publication(serializer, payload, routing_key)

      response = @exchanges[routing_key].publish(payload, {persistent: true}.
        merge(properties).
        merge(global_properties).
        merge(non_overridable_properties))

      channel.wait_for_confirms if config[:force_publisher_confirms]

      response
    end

    private

    def log_publication(serializer, payload, routing_key)
      logger.debug {
        spec =
          if serializer.binary?
            "#{payload.bytesize} bytes message"
          else
            "message '#{payload}'"
          end
        "publishing #{spec} to #{routing_key}"
      }
    end

    def raise_publish_error(reason, routing_key, message)
      msg = "unable to publish - #{reason}. Message: #{JSON.dump(message)}, Routing key: #{routing_key}."
      logger.error(msg)
      raise PublishError, msg
    end

    def ensure_connection!(routing_key, message)
      raise_publish_error('no connection to broker', routing_key, message) unless connection
      raise_publish_error('connection is closed', routing_key, message) unless connection.open?
    end

    def generate_id
      SecureRandom.uuid
    end

    def global_properties
      Hutch.global_properties.respond_to?(:call) ? Hutch.global_properties.call : Hutch.global_properties
    end
  end
end
