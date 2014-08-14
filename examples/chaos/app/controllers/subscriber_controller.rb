class SubscriberController < ApplicationController

  include ApplicationHelper

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end
    r = make_response

    PN.instance.pn.publish(:http_sync => false, :message => "Sending to client: #{r['payload']}", :channel => "chaos_admin") do |x|
      puts x
    end

    render :js => r["payload"], :status => http_sub_status
  end

  def make_response

    messages = PN.instance.fetch_q
    timetoken = @PNTIME
    d = messages["data"]["message"]
    tt = timetoken.to_s

    if messages["well_formed_json"]

        if http_sub_status != 200
          return { "payload" => ResponseSubscribe.new(:timetoken => tt, :messages => messages["data"]["message"], :channel => "bot").to_403 }
        else
          return { "payload" => ResponseSubscribe.new(:timetoken => tt, :messages => messages["data"]["message"], :channel => "bot").to_known_json }
        end

    else
      if messages["channels"].present?
        channelOverride = messages["channels"]
      end

      if channelOverride.present?

        {"payload" => "[ " + d + ", " + tt.to_json + ", " + channelOverride.to_json + "]"}

      else
        if http_sub_status != 200

          {"payload" =>
               '{"status":' + http_sub_status.to_s + ',"service":"Access Manager","error":true,"message":"Forbidden","payload":{"channels":["bot-pnpres"]}}'
          }

        else

          {"payload" => "[ " + d + ", " + tt.to_json + "]"}
        end

      end

    end

  end

end




