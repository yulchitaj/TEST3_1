class SubscriberController < ApplicationController

  def subscribe
    while !PN.instance.fetch_ready?
      sleep(0.25)
    end

    render :js => make_msg(0)
   end

  def make_msg(timetoken, messages = [])

    messages = PN.instance.fetch_q
    timetoken = @PNTIME

    #t = @PN.time(:http_sync => true)

    [messages, timetoken.to_s].to_json
  end
end
