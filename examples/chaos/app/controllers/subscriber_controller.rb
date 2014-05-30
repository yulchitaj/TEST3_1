class SubscriberController < ApplicationController

  def subscribe
      render :js => make_msg(0)
    end
  end


  def make_msg(timetoken, messages = [])


    #time = PN.instance.time[0].message
    #puts "*************" + time.to_s

    messages = [@PNTIME.to_s]

      timetoken = @PNTIME

    [ messages, timetoken.to_s].to_json



end
