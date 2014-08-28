class Payload

  attr_accessor :message, :channels, :well_formed_json, :from

  def initialize(options)
    @message = options[:message]
    @channels = options[:channels]
    @well_formed_json = options[:well_formed_json] || false
    @from = options[:from]
  end

  def is_fragment?
    return !self.well_formed_json
  end

  def is_well_formed?
    return self.well_formed_json
  end

  def is_raw_response?
    return self.from == "response"
  end

  def get_channels(real_subscribed_channels, channel_options)

    client_channels = []
    is_mxed = real_subscribed_channels.length > 1

    # If channels are disabled or it came from a raw "response" type, just return empty
    if channel_options == "none" || self.from == "response"
      return client_channels
    end

    if channel_options == "default"

      # If Well Formed
      if is_well_formed?
        if is_mxed || !is_mxed
          # Just use the channel it came in on
          return [self.channels]
        end

      # If Fragmented
      elsif !is_well_formed?

        if is_mxed
          # Return a nice looking, correct CSV channel list
          self.message.length.times { |x| client_channels.push(real_subscribed_channels[0]) }
          return client_channels

        elsif !is_mxed
          # Return the first real subscribed channel, or if we've populated the channel element, use that
          client_channels = self.channels.present? ? [self.channels] : [real_subscribed_channels[0]]
          return client_channels

        end
      end
    end

    if channel_options["custom"].present?

      # If Well Formed || ! Well Formed, If MXed or not MXed
      if is_well_formed? || !is_well_formed?
        if is_mxed || !is_mxed
          client_channels = channel_options["custom"]
          return client_channels
        end
      end
    end
  end
end