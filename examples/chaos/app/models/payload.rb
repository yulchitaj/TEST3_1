class Payload

  attr_accessor :message, :channels, :well_formed_json, :frag_channels, :from

  def initialize(options)
    @message = options[:message]
    @channels = options[:channels]
    @well_formed_json = options[:well_formed_json]
    @frag_channels = options[:frag_channels]
    @from = options[:from]
  end

  def get_channels(real_subscribed_channels, channel_options)

    client_channels = []


    if channel_options == "none"
      return []
    end

    if channel_options["custom"].present?

      if channel_options["custom"].class == String # If channels is a string, duplicate it for each message
        self.message.length.times { |x| client_channels.push(channel_options["custom"]) }
        return client_channels

      elsif channel_options["custom"].class == Array
        client_channels = channel_options["custom"]
        return client_channels
      end

    end


    if channel_options == "default"

      if real_subscribed_channels.length > 1

        # Multiplexing Response

        if self.message.length < 2
          client_channels = self.channels.present? ? [self.channels] : [real_subscribed_channels[0]]
        else
          if self.message.class == Array
            self.message.length.times { |x| client_channels.push(real_subscribed_channels[0]) }
            return client_channels
          else
            client_channels = self.channels.present? ? [self.channels] : [real_subscribed_channels[0]]
            return client_channels
          end
        end

      else

        # Non-MX Response
        client_channels = [real_subscribed_channels[0]]

      end
    end


  end
end