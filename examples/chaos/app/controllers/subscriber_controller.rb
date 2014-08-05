class SubscriberController < ApplicationController

  include ApplicationHelper

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end

    r = make_response

    render :js => r["payload"], :status => http_sub_status

  end

  def make_response

    messages = PN.instance.fetch_q

    timetoken = @PNTIME

    #t = @PN.time(:http_sync => true)

    d = messages["data"]["message"]
    ch = messages["data"]["channel"]

    tt = timetoken.to_s
    json = messages["json"]

    if json
      if @channels.length > 1

        if http_sub_status != 200

          {"payload" =>
               '{"status":' + http_sub_status.to_s + ',"service":"Access Manager","error":true,"message":"Forbidden","payload":{"channels":["bot-pnpres"]}}'
          }

        else

          {"payload" => [[d], tt, ch].to_json }

        end

          else

        if http_sub_status != 200

          {"payload" =>
               '{"status":' + http_sub_status.to_s + ',"service":"Access Manager","error":true,"message":"Forbidden","payload":{"channels":["bot-pnpres"]}}'
          }

        else

          {"payload" => [[d], tt].to_json }

        end

      end


    else

      if messages["channels"].present?
        channels = messages["channels"]
      end

      if channels.present?

        {"payload" => "[ " + d + ", " + tt.to_json + ", " + channels.to_json + "]"}

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




