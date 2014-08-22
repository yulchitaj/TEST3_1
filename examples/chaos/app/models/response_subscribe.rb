class ResponseSubscribe
  #include ApplicationHelper

  attr_accessor :messages, :timetoken, :channels, :fragmented, :response, :http_response_status

  def initialize(options)
    @http_response_status = options[:http_response_status]
    @response = options[:response]

    if @response.blank?

      @timetoken = options[:timetoken]
      @fragmented = options[:fragmented]

      # either has response, or messages payload
      @messages = package(options[:messages]) || package(options[:message])
      #@channels = package(options[:channels]) || package(options[:channel])
      @channels = options[:channels] || options[:channel]
    end

  end

  def raw
    return @response.to_json
  end

  def package(payload)
    if payload.class == Array
      return @fragmented ? payload : [payload]

    elsif payload.class == String
      return [payload.split(",")][0]
    end
  end

  def to_well_formed_json

    if is_403?
      return to_403
    end

    if @channels.length == 0
      return [@messages, @timetoken.to_s].to_json
    else
      return [@messages, @timetoken.to_s, @channels.join(",")].to_json
    end
  end

  # TODO - known envelope, unknown / unpredictable values
  def to_fragmented_json
    if @channels.length == 0
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + "]"
    else
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + ", " + @channels.join(",").to_json + "]"
    end
  end

  # TODO - could be anything - malformed envelope, html, etc
  def to_unknown_response
    if @channels.length == 0
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + "]"
    else
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + ", " + @channels.join(",").to_json + "]"
    end
  end

  def is_403?
    @http_response_status == 403
  end

  def to_403
    {
        "status" => http_response_status,
        "service" => "Access Manager",
        "error" => true,
        "message" => "Forbidden",
        "payload" => {"channels" => [@channels[0]]}
    }.to_json
  end
end


