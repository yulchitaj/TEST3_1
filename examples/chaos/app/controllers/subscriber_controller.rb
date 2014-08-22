class SubscriberController < ApplicationController
  include ApplicationHelper

  attr_accessor :payload

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end

    make_response

    PN.instance.pn.publish(:http_sync => false, :message => "(#{@real_subscribed_channels}) Sending to client: #{@payload}", :channel => "chaos_admin") do |x|
      puts x
    end

    render :js => @payload, :status => http_sub_status
  end


  def make_response

    messages = PN.instance.fetch_q

    client_channels = []

    if channel_options == "default"

      if @real_subscribed_channels.length > 1

        if messages["data"]["message"].length < 2
        client_channels = messages["channels"].present? ? [messages["channels"]] : [@real_subscribed_channels[0]]
        else

          if messages["data"]["message"] == Array
            messages["data"]["message"].length.times { |x| client_channels.push(@real_subscribed_channels[0]) }
          else
            client_channels = messages["channels"].present? ? [messages["channels"]] : [@real_subscribed_channels[0]]
          end




        end

      else
        clientChannels = []
      end

    elsif channel_options == "none"
      clientChannels = []

    elsif channel_options["custom"].present?

      if channel_options["custom"].class == String # If channels is a string, duplicate it for each message
        messages["data"]["message"].length.times { |x| client_channels.push(channel_options["custom"]) }

      elsif channel_options["custom"].class == Array
        client_channels = channel_options["custom"]
      end
    end

    ## Well-Formed
    if messages["well_formed_json"]
      subscribe_response = ResponseSubscribe.new(:timetoken => @PNTIME.to_s,
                                                 :messages => messages["data"]["message"],
                                                 :channel => client_channels,
                                                 :http_response_status => http_sub_status)

      @payload = subscribe_response.to_well_formed_json

      ## Fragmented
    elsif messages["data"]["response"].present?
      @payload = ResponseSubscribe.new(:fragmented => true,
                                       :response => messages["data"]["response"]).raw
    else

      subscribe_response = ResponseSubscribe.new(:fragmented => true,
                                                 :timetoken => @PNTIME.to_s,
                                                 :messages => messages["data"]["message"],
                                                 :channel => client_channels,
                                                 :http_response_status => http_sub_status)
      @payload = subscribe_response.to_fragmented_json


    end
  end
end
