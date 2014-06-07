class SubscriberController < ApplicationController

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end

    r = make_msg

    if r["json"]
      render :js => r["payload"]
    else
      render :js => r["payload"]
    end


   end

  def make_msg


    messages = PN.instance.fetch_q

    timetoken = @PNTIME

    #t = @PN.time(:http_sync => true)


    d = messages["data"]
    tt = timetoken.to_s
    json = messages["json"]

    if json
      {"payload" =>  [ [    d    ] ,     tt    ].to_json, "json" => json}
    else
      {"payload" => "[ [" + d + "] , " + tt + "]" ,       "json" => json.to_s + "]" }
    end


  end
end
