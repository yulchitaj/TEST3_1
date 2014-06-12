class SubscriberController < ApplicationController

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end

    r = make_response
    render :js => r["payload"] #, :status => 418

   end

  def make_response

    messages = PN.instance.fetch_q

    timetoken = @PNTIME
    puts "RUNMODE: #{@RUN_MODE}"

    #t = @PN.time(:http_sync => true)

    puts "Channels: #{@channels}"

    d = messages["data"]["message"]
    ch = messages["data"]["channel"]

    tt = timetoken.to_s
    json = messages["json"]

    if json
      if @channels.length > 1
        {"payload" =>  [ [    d    ] ,     tt, ch    ].to_json, "json" => json}
      else
        {"payload" =>  [ [    d    ] ,     tt    ].to_json, "json" => json}
      end


    else

      {"payload" => "[ [" + d + "] , " + tt + "]" ,       "json" => json.to_s + "]" }

    end

  end
end




