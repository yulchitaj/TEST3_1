class SubscriberController < ApplicationController
  include ApplicationHelper

  attr_accessor :subscribe_response

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end

    make_response

    PN.instance.pn.publish(:http_sync => false, :message => "Real Subbed Channels: (#{@real_subscribed_channels})Sending to client: #{@subscribe_response}", :channel => "chaos_admin") do |x|
      nil
    end

    render :js => @subscribe_response, :status => http_sub_status
  end


  def make_response

    payload = PN.instance.fetch_q

    client_channels = payload.get_channels(@real_subscribed_channels, channel_options)
    puts "client_channels: #{client_channels}"

    ## Well-Formed
    if payload.well_formed_json
      subscribe_response = ResponseSubscribe.new(:timetoken => @PNTIME.to_s,
                                                 :messages => payload.message,
                                                 :channel => client_channels,
                                                 :http_response_status => http_sub_status)

      @subscribe_response = subscribe_response.to_well_formed_json

      ## Response
    elsif payload.from == "response"
      @subscribe_response = ResponseSubscribe.new(:fragmented => true,
                                                  :response => payload.message).raw
    else
      ## Fragmented Messages

      subscribe_response = ResponseSubscribe.new(:timetoken => @PNTIME.to_s,
                                                 :messages => payload.message,
                                                 :channel => client_channels,
                                                 :http_response_status => http_sub_status,
                                                 :fragmented => true)
      @subscribe_response = subscribe_response.to_fragmented_json


    end
  end
end
