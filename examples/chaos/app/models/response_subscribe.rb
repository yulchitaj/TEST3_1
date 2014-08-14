class ResponseSubscribe
  include ApplicationHelper

  attr_accessor :messages, :timetoken, :channels

  def initialize(options)
    @timetoken = options[:timetoken]

    @messages = package(options[:messages]) || package(options[:message])
    @channels = package(options[:channels]) || package(options[:channel])

  end

  def package(payload)
    if payload.class == Array
      return [payload]

    elsif payload.class == String
      return [payload.split(",")][0]
    end
  end

  def to_known_json
    if @channels.length < 2
      return [ @messages, @timetoken.to_s].to_json
    else
      return [ @messages, @timetoken.to_s, [@channels.join(",")]].to_json
    end
  end

  # TODO - known envelope, unknown / unpredictable values
  def to_unknown_json
    if @channels.length < 2
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + "]"
    else
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + ", " + @channels.join(",").to_json + "]"
    end
  end

  # TODO - could be anything - malformed envelope, html, etc
  def to_unknown_response
    if @channels.length < 2
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + "]"
    else
      return "[ " + @messages.to_json + ", " + @timetoken.to_json + ", " + @channels.join(",").to_json + "]"
    end
  end

  def to_403
    #return '{"status":' + http_sub_status.to_s + ',"service":"Access Manager","error":true,"message":"Forbidden","payload":{"channels":[' + @channels[0] + ']}}'
    return {
        "status" => http_sub_status,
        "service" => "Access Manager",
        "error" => true,
        "message" => "Forbidden",
        "payload" => {"channels" => [@channels[0]]}
    }.to_json
  end

end


